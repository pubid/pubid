#!/usr/bin/env ruby
# Test script to debug IEEE parser failures

require_relative "../../../lib/pubid_new"

# Test cases for failing proper IEEE standards
test_cases = [
  # INT suffix patterns
  "IEEE Std 1076/INT-1991",
  "IEEE Std 1003.1-1988/INT, 1992 Edition",

  # Corrigendum patterns
  "IEEE Std 1003.1-2001/Cor 1-2002",
  "IEEE Std 1003.1-2008/Cor 2-2016",

  # Copublisher patterns
  "IEEE Std 1299/C62.22.1-1996",
  "IEEE Std 1635-2012/ASHRAE Guideline 21-2012",

  # Conformance patterns
  "IEEE Std 802.16/Conformance01-2003",
  "IEEE Std 1904.1/Conformance02-2014",

  # Joint standards
  "IEEE Std 960-1989, Std 1177-1989",
]

puts "Testing IEEE Parser Failures"
puts "=" * 80

test_cases.each do |identifier|
  puts "\nTesting: #{identifier}"
  puts "-" * 80

  begin
    result = PubidNew::Ieee.parse(identifier)
    puts "✓ SUCCESS: Parsed as #{result.class}"
    puts "  Result: #{result.to_s}"
  rescue Parslet::ParseFailed => e
    puts "✗ FAILED: #{e.message}"
  rescue => e
    puts "✗ ERROR: #{e.class} - #{e.message}"
  end
end

puts "\n" + "=" * 80
