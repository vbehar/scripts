#!/usr/bin/env ruby

# a little script to do some stats on the members
# use a csv file as input 

require 'date'

header = nil
members = []

File.open("adherents.csv").each_line {|l|
  if header
    members << l.strip.split(";")
  else
    header = l.strip.split(";")
  end
}

puts "#{members.size} members"

def getAge(birthDate)
  date = Date.strptime(birthDate, "%d/%m/%Y")
  days = (Date.today - date).to_i
  return (Date.parse("1970-01-01") + days).year - 1970
end


res = members.inject(0) do |res, m|
  postalCode = m[header.index("CODE POSTAL")]
  age = getAge(m[header.index("NE LE")]).to_i
  if age > 40 && age <= 100 && postalCode != "94340"
    res += 1
  else
    res += 0
  end
end
puts "res : #{res}"

