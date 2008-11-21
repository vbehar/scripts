#!/usr/bin/env ruby

## svnlog2jabber
# get the log of an SVN repo, and send it through Jabber
# this script is meant to be run periodically with cron
# it replaces a svn hook (after commit) when you don't have
# access to the svn server config

## configuration
data_file_path = "svnlog2jabber.rev"
svn_url = ""
jabber_id = ""
jabber_password = ""
jabber_recipients = %w()

## you need rubygems and xml-object / xmpp4r-simple
require 'time'
require 'rubygems'
require 'xml-object'
require 'xmpp4r-simple'

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
    @date = Time.parse(entry.date) + 3600
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
  
  def to_jabber_msg(jabber_id_recipient)
    msg = Jabber::Message.new(jabber_id_recipient)
    msg.type = :chat
    msg.body = "r#{@revision.to_s} (#{@date.strftime('%d/%m/%Y %H:%M:%S')})\n"
    msg.body += "#{@author}\n\n"
    msg.body += "#{@message}\n\n"
    @files.each do |file|
      msg.body += "#{file.action} #{file.path}\n"
    end
    msg
  end
end

def parse_svn_log(svnlogxml)
  log = XMLObject.new(svnlogxml)
  entries = log.logentrys rescue [log.logentry]
  entries.collect { |entry| LogEntry.new(entry) }
end

unless File.exists?(data_file_path)
  entry = parse_svn_log(`svn log #{svn_url} -l 1 -v --xml`).first
  File.open(data_file_path, "w") {|f| f.write(entry.revision.to_s)}
  Process.exit
end

last_rev = File.read(data_file_path).to_i

entries = parse_svn_log(`svn log #{svn_url} -r #{last_rev}:HEAD -v --xml`)
entries.reject! { |entry| entry.revision == last_rev }
Process.exit if entries.empty?

im = Jabber::Simple.new(jabber_id, jabber_password)
entries.each do |entry|
  jabber_recipients.each do |recipient|
    im.send! entry.to_jabber_msg(recipient)
    sleep 1
  end
end
im.disconnect

last_rev = entries.collect {|entry| entry.revision }.max
File.open(data_file_path, "w") {|f| f.write(last_rev.to_s)}

