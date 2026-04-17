#!/usr/bin/env ruby
# Debug joint standard parsing

require_relative "../../../lib/pubid"

input = "IEEE Std 960-1989, Std 1177-1989"
puts "Input: #{input}"

# Test preprocessing
test = input.gsub(/(\d{4}),\s+Std\s/, '\1 and IEEE Std ')
puts "After preprocessing: #{test}"

# Try parsing
begin
  result = Pubid::Ieee.parse(input)
  puts "Success: #{result.class}"
  puts "Result: #{result}"
rescue StandardError => e
  puts "Failed: #{e.class} - #{e.message}"
end
