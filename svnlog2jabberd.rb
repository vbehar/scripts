#!/usr/bin/env ruby

## svnlog2jabberd
# daemon script that periodically fetch the log of an SVN repo,
# and send it through Jabber to a conference room
# it replaces a svn hook (after commit) when you don't have
# access to the svn server config

## configuration
config = {}
config[:data_file_path] = "svnlog2jabberd.rev"
config[:svn_url] = ""
config[:jabber_id] = ""
config[:jabber_password] = ""
config[:jabber_conference] = ""
config[:check_interval] = '1m'

## you need rubygems and xml-object, xmpp4r and rufus/scheduler
require 'time'
require 'rubygems'
require 'xml-object'
require 'xmpp4r'
require 'xmpp4r/muc/helper/mucclient'
require 'rufus/scheduler'

class ModifiedFile
  attr_reader :path, :action
  
  def initialize(path, action)
    @path = path
    @action = action
  end
end

class LogEntry
  attr_reader :revision, :date, :author, :message, :files
  
  def initialize(entry)
    @revision = entry.revision.to_i
    @date = Time.parse(entry.date)
    @date = @date.getlocal if @date.utc?
    @author = entry.author
    @message = entry.msg
    @files = []
    if entry.paths.is_a?(Array)
      entry.paths.each do |path|
        @files << ModifiedFile.new(path, path.action)
      end
    else
     @files << ModifiedFile.new(entry.paths.path, entry.paths.path.action)
    end
  end
  
  def to_jabber_msg
    txt = "r#{@revision.to_s} (#{@date.strftime('%d/%m/%Y %H:%M:%S')})\n"
    txt += "#{@author}\n\n"
    txt += "#{@message}\n\n"
    @files.each do |file|
      txt += "#{file.action} #{file.path}\n"
    end
    Jabber::Message::new(nil, txt)
  end
end

def parse_svn_log(svnlogxml)
  log = XMLObject.new(svnlogxml)
  entries = log.logentrys rescue [log.logentry]
  entries.collect { |entry| LogEntry.new(entry) }
end

def check_svn(config, muc)
  last_rev = File.read(config[:data_file_path]).to_i

  entries = parse_svn_log(`svn log #{config[:svn_url]} -r #{last_rev}:HEAD -v --xml`)
  entries.reject! { |entry| entry.revision == last_rev }
  return if entries.empty?

  entries.each do |entry|
    muc.send entry.to_jabber_msg
    sleep 1
  end

  last_rev = entries.collect {|entry| entry.revision }.max
  File.open(config[:data_file_path], "w") {|f| f.write(last_rev.to_s)}
end

unless File.exists?(config[:data_file_path])
  entry = parse_svn_log(`svn log #{config[:svn_url]} -l 1 -v --xml`).first
  File.open(config[:data_file_path], "w") {|f| f.write(entry.revision.to_s)}
end

xmpp = Jabber::Client.new(Jabber::JID::new(config[:jabber_id]))
xmpp.connect
xmpp.auth(config[:jabber_password])

muc = Jabber::MUC::MUCClient.new(xmpp)
muc.my_jid = 'SVN'
muc.join(config[:jabber_conference])

scheduler = Rufus::Scheduler.start_new

scheduler.every config[:check_interval] do
  check_svn(config,muc)
end

scheduler.join

muc.exit
xmpp.close

