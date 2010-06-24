#!/usr/bin/env ruby

# a little script to manipulate clewarecontrol
# with input from a hudson instance

HUDSON_URL = ""
HUDSON_USER = ""
HUDSON_PASSWORD = ""
HUDSON_JOBS = %w( )
HUDSON_USE_ALL_JOBS = false

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
    when :all, "all"
      puts "setting all"
      `#{CLEWARECONTROL} -as 0 1 -as 1 1 -as 2 1`
    else
      puts "setting nothing"
      `#{CLEWARECONTROL} -as 0 0 -as 1 0 -as 2 0`
  end
end

def animate_colors(color1, color2, duration)
  duration.times do
    set_color color2
    sleep 0.2
    set_color color1
    sleep 0.5
    set_color color2
    sleep 0.1
    set_color color1
    sleep 0.2
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
  jobs = data["jobs"].select{|job| HUDSON_USE_ALL_JOBS || HUDSON_JOBS.include?(job["name"])}
  colors = jobs.collect{|job| job["color"]}.uniq
  if ( colors.include?("red") || colors.include?("red_anime") )
    animate_colors :red, :none, 50
  elsif ( colors.include?("yellow") || colors.include?("yellow_anime") )
    animate_colors :yellow, :none, 50
  elsif ( colors.include?("blue") || colors.include?("blue_anime") )
    set_color :green
  else # grey disabled aborted
    set_color :none
  end
else
  puts "oops"
  puts resp.status
  animate_colors :all, :none, 50
end

