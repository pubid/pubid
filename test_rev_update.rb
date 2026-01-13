# frozen_string_literal: true

require_relative "lib/pubid_new"

# Test update after revision
test_cases = [
  "NIST.IR.8115r1-upd",
  "NIST.SP.800-108r1-upd1",
  "NIST.AMS.300-8r1/upd",
]

test_cases.each do |test_case|
  puts "\n=== Testing: #{test_case} ==="
  result = PubidNew::Nist::Parser.parse(test_case)
  puts "Parser result: #{result.inspect}"

  identifier = PubidNew::Nist.parse(test_case)
  puts "Parsed format: #{identifier.parsed_format.inspect}"
  puts "Edition: #{identifier.edition.inspect}"
  puts "Update component: #{identifier.update_component.inspect}"
  puts "To_s: #{identifier.to_s}"
end
