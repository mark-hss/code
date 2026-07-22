#!/usr/bin/env ruby
# frozen_string_literal: true
filename = ARGV[0]

if filename.nil?
  warn "Usage: ruby inspect_code.rb FILE.rb"
  exit 1
end

unless File.file?(filename)
  warn "File not found: #{filename}"
  exit 1
end

iseq = RubyVM::InstructionSequence.compile_file(filename)

puts iseq.disasm
