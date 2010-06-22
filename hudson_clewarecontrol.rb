#!/usr/bin/env ruby

# a little script to manipulate clewarecontrol
# with input from a hudson instance

HUDSON_URL = ""
HUDSON_USER = ""
HUDSON_PASSWORD = ""
HUDSON_JOBS = %w( )

CLEWARECONTROL = "/usr/bin/clewarecontrol"

require 'rubygems'
require 'patron'
require 'json'

def set_color(color)
  case color
    when :red, "red"
      puts "setting red"
      `#{CLEWARECONTROL} -as 0 1 -as 1 0 -as 2 0`
    when :yellow, "yellow"
      puts "setting yellow"
      `#{CLEWARECONTROL} -as 0 0 -as 1 1 -as 2 0`
    when :green, "green"
      puts "setting green"
      `#{CLEWARECONTROL} -as 0 0 -as 1 0 -as 2 1`
    else
      puts "setting nothing"
      `#{CLEWARECONTROL} -as 0 0 -as 1 0 -as 2 0`
  end
end

sess = Patron::Session.new
sess.timeout = 30
sess.base_url = HUDSON_URL
sess.username = HUDSON_USER
sess.password = HUDSON_PASSWORD
sess.auth_type = :basic

resp = sess.get("/api/json")
if resp.status < 400
  data = JSON.parse resp.body
  jobs = data["jobs"].select{|job| HUDSON_JOBS.include?job["name"]}
  colors = jobs.collect{|job| job["color"]}.uniq
  if colors.include?"red"
    set_color :red
  elsif colors.include?"yellow"
    set_color :yellow
  elsif colors.include?"blue"
    set_color :green
  else
    set_color :blank
  end
else
  puts "oups"
  puts resp.status
end

