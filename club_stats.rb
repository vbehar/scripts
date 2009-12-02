#!/usr/bin/env ruby

# a little script to do some stats on the members
# use a csv file as input 

require 'date'

class Club
  attr_reader :header, :members

  def initialize(csv_file, csv_separator, &block)
    File.open(csv_file).each_line do |line|
      if @header
        data = line.strip.split(csv_separator)
        hash = {}
        @header.size.times {|i| hash[ @header[i] ] = data[i] }
        @members = [] unless @members
        @members << Member.new(hash)
      else
        @header = line.strip.split(csv_separator)
      end
    end
    block.call(@members) if block
  end
end

class Member
  attr_reader :data
  attr_reader :age

  def initialize(hash)
    @data = hash
    @data.each do |key, value|
      method_name = key.downcase.gsub(" ", "_").to_sym
      self.class.send(:define_method, method_name) { @data[key] } unless self.class.method_defined? method_name
    end
  end

  def age
    return @age if @age
    birth_date = Date.strptime(ne_le, "%d/%m/%Y")
    days = (Date.today - birth_date).to_i
    @age = (Date.parse("1970-01-01") + days).year - 1970
  end
end


Club.new("adherents.csv", ";") do |members|
  puts "<= 12 && 94340 : " + members.select {|m| m.age <= 12 && m.code_postal == "94340" }.size.to_s
  puts "<= 12 && !94340 : " + members.select {|m| m.age <= 12 && m.code_postal != "94340" }.size.to_s
  puts "<= 12 : " + members.select {|m| m.age <= 12 }.size.to_s
  puts "12 < x <= 18 && 94340 : " + members.select {|m| m.age > 12 && m.age <= 18 && m.code_postal == "94340" }.size.to_s
  puts "12 < x <= 18 && !94340 : " + members.select {|m| m.age > 12 && m.age <= 18 && m.code_postal != "94340" }.size.to_s
  puts "12 < x <= 18 : " + members.select {|m| m.age > 12 && m.age <= 18 }.size.to_s
  puts "18 < x <= 25 && 94340 : " + members.select {|m| m.age > 18 && m.age <= 25 && m.code_postal == "94340" }.size.to_s
  puts "18 < x <= 25 && !94340 : " + members.select {|m| m.age > 18 && m.age <= 25 && m.code_postal != "94340" }.size.to_s
  puts "18 < x <= 25 : " + members.select {|m| m.age > 18 && m.age <= 25 }.size.to_s
  puts "25 < x <= 40 && 94340 : " + members.select {|m| m.age > 25 && m.age <= 40 && m.code_postal == "94340" }.size.to_s
  puts "25 < x <= 40 && !94340 : " + members.select {|m| m.age > 25 && m.age <= 40 && m.code_postal != "94340" }.size.to_s
  puts "25 < x <= 40 : " + members.select {|m| m.age > 25 && m.age <= 40 }.size.to_s
  puts "> 40 && 94340 : " + members.select {|m| m.age > 40 && m.code_postal == "94340" }.size.to_s
  puts "> 40 && !94340 : " + members.select {|m| m.age > 40 && m.code_postal != "94340" }.size.to_s
  puts "> 40 : " + members.select {|m| m.age > 40 }.size.to_s
  puts "94340 : " + members.select {|m| m.code_postal == "94340" }.size.to_s
  puts "!94340 : " + members.select {|m| m.code_postal != "94340" }.size.to_s
  puts "total : " + members.size.to_s
end


