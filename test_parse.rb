#!/usr/bin/env ruby
require_relative 'spec/spec_helper'

test_cases = [
  "ISO 4037-1979/Add. 1-1983(F)",
  "ISO 2631/DAD 1",
  "ISO 2553/DAD 1:1987"
]

test_cases.each do |input|
  puts "\nInput: #{input}"
  begin
    parsed = PubidNew::Iso.parse(input)
    puts "  Base number: #{parsed.base_identifier.number.value}"
    puts "  Base part: #{parsed.base_identifier.part&.value || 'nil'}"
    puts "  Base date: #{parsed.base_identifier.date&.year || 'nil'}"
    puts "  Add number: #{parsed.number.value}"
    puts "  Add part: #{parsed.part&.value || 'nil'}"
    puts "  Add date: #{parsed.date&.year || 'nil'}"
    puts "  Output: #{parsed.to_s}"
  rescue => e
    puts "  ERROR: #{e.class}: #{e.message}"
  end
end