#!/usr/bin/env ruby
# Debug test for conformance patterns

require_relative "../../../lib/pubid"

test_case = "IEEE Std 802.16/Conformance01-2003"

puts "Testing: #{test_case}"
puts "-" * 80

# Try with instance method (no preprocessing)
begin
  parser = Pubid::Ieee::Parser.new
  result = parser.parse(test_case)
  puts "Instance parse tree:"
  puts result.inspect
rescue Parslet::ParseFailed => e
  puts "Instance parse failed: #{e.message}"
end

# Try with class method (with preprocessing)
puts "\nTrying class method (with preprocessing)..."
begin
  parser = Pubid::Ieee::Parser
  result = parser.parse(test_case)
  puts "Class parse tree:"
  puts result.inspect
rescue Parslet::ParseFailed => e
  puts "Class parse failed: #{e.message}"
end

# Now try the full parse
puts "\nTrying full Pubid::Ieee.parse..."
begin
  id = Pubid::Ieee.parse(test_case)
  puts "\n✓ SUCCESS: Parsed as #{id.class}"
  puts "Result: #{id.to_s}"
rescue Parslet::ParseFailed => e
  puts "\n✗ FAILED: #{e.message}"
rescue => e
  puts "\n✗ ERROR: #{e.class} - #{e.message}"
end
