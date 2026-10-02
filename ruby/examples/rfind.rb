#!/usr/bin/env ruby
# frozen_string_literal: true
# 
# Name: rfind.rb
# Purpose: example of Array#rfind reverse find introduced in ruby 4.0
# Usage: ruby rfind.rb
#
numbers = [10, 25, 30, 45, 50]

# Find the first number below 40,normal find 
numbers.find { |n| n < 40 }
#
# # Find the first number below 40, reverse search
numbers.rfind { |n| n < 40 }
