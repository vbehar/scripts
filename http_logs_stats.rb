#!/usr/bin/env ruby

# a little script to do some stats
# on an http logs file (apache style)

log_file = "all_logs"


stats = {}
File.open(log_file).each_line do |line|
  elems = line.split(" ")
  path = elems[6]
  path = path.split("?").first
  stats[path] = 0 unless stats.include?path
  stats[path] = stats[path] + 1
end

stats.sort.each do |path, hits|
  puts "#{hits} #{path}"
end

