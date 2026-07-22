#!/usr/bin/env ruby
# frozen_string_literal: true
code = <<-RUBY
  x = 10
  y = 20
  puts x + y
RUBY

iseq = RubyVM::InstructionSequence.compile(code)

puts iseq.disasm
