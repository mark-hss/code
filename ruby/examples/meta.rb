#!/usr/bin/env ruby
# frozen_string_literal: true
#
# # Name: meta.rb
# # Purpose: example of define_method, creates dynamic methods
# # Usage: ruby meta.rb
class DynamicMethod
  def self.create_method(name)
    define_method(name) do |*args|
      puts "called #{name} with #{args.inspect}"
    end
  end
end

#name our dynamic method
DynamicMethod.create_method(:greet)

obj = DynamicMethod.new

#greet was created at runtime
obj.greet("hello", "world")
