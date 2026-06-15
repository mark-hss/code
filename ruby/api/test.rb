#!/usr/bin/env ruby

def greet(name)
  puts("Hello #{name}")
end
puts "enter name"
n = gets.chomp
greet(n)
