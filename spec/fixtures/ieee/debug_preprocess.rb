#!/usr/bin/env ruby
# Debug preprocessing

require_relative "../../../lib/pubid"

test_case = "IEEE Std 802.16/Conformance01-2003"

# Manually run preprocessing steps
cleaned = test_case

# Step from line 971 - NEW regex with negative lookahead
step_result = cleaned.gsub(/(\d)\/Conformance(\d+)(?!-\d{4})/,
                           '\1 /Conformance\2')
puts "Before line 971: #{cleaned}"
puts "After line 971: #{step_result}"
puts "Match: #{begin
  cleaned.match(/(\d)\/Conformance(\d+)(?!-\d{4})/).inspect
rescue StandardError
  'no match'
end}"

# Also test a malformed pattern (should get space added)
malformed = "1904.1(TM)/Conformance02"
malformed_result = malformed.gsub(/(\d)\/Conformance(\d+)(?!-\d{4})/,
                                  '\1 /Conformance\2')
puts "\nMalformed test: #{malformed}"
puts "After fix: #{malformed_result}"
