# frozen_string_literal: true

require_relative "lib/pubid_new"

# Test part number patterns
test_cases = [
  "NIST.IR.85-3273-37",
  "NIST.IR.85-3273-37-upd1",
  "NIST.IR.8286C-upd1",
]

test_cases.each do |test_case|
  puts "\n=== Testing: #{test_case} ==="
  result = PubidNew::Nist::Parser.parse(test_case)
  puts "Parser result: #{result.inspect}"

  identifier = PubidNew::Nist.parse(test_case)
  puts "First number: #{identifier.first_number.inspect}"
  puts "Second number: #{identifier.second_number.inspect}"
  puts "Edition: #{identifier.edition.inspect}"
  puts "Update component: #{identifier.update_component.inspect}"
  puts "To_s: #{identifier.to_s}"
end
