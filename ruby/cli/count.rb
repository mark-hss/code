#!/usr/bin/env ruby
# frozen_string_literal: true
# Name: count.rb
# Purpose: count top 10 word occurances in file
# Usage: ruby count.rb
file=ARGV[0]

words = Hash.new(0)

File.open(file, "r").each_line do |line|
  line.scan(/\b\w+\b/) {|i| words[i] +=1}
end

sorted = words.sort_by {|a| a[1]}

temp = sorted.length

10.times do
  temp -= 1
  puts "\"#{sorted[temp][0]}\" has #{sorted[temp][1]} occurances"
end
