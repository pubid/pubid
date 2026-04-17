#!/usr/bin/env ruby
# Test if parser can handle "and" pattern

require_relative "../../../lib/pubid"

# Test with the preprocessed version
input = "IEEE Std 960-1989 and IEEE Std 1177-1989"
puts "Testing: #{input}"

# First check if Base.parse handles "and"
puts "\n1. Testing Base.parse (with 'and' handling):"
begin
  result = Pubid::Ieee::Identifiers::Base.parse(input)
  puts "Success: #{result.class}"
  puts "Result: #{result}"
rescue StandardError => e
  puts "Failed: #{e.class} - #{e.message[0..100]}"
end

# Then test if Parser can handle it directly
puts "\n2. Testing Parser.parse directly:"
begin
  result = Pubid::Ieee::Parser.parse(input)
  puts "Success: #{result.inspect}"
rescue StandardError => e
  puts "Failed: #{e.class} - #{e.message[0..100]}"
end

# Also test instance parse (no preprocessing)
puts "\n3. Testing instance parse (no preprocessing):"
begin
  parser = Pubid::Ieee::Parser.new
  result = parser.parse(input)
  puts "Success: #{result.inspect}"
rescue StandardError => e
  puts "Failed: #{e.class} - #{e.message[0..100]}"
end
