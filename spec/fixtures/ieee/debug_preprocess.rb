#!/usr/bin/env ruby
# Debug preprocessing

require_relative "../../../lib/pubid"

test_case = "IEEE Std 802.16/Conformance01-2003"

# Manually run preprocessing steps
cleaned = test_case

# Step from line 971 - NEW regex with negative lookahead
cleaned.gsub(/(\d)\/Conformance(\d+)(?!-\d{4})/,
             '\1 /Conformance\2')

# Also test a malformed pattern (should get space added)
malformed = "1904.1(TM)/Conformance02"
malformed.gsub(/(\d)\/Conformance(\d+)(?!-\d{4})/,
               '\1 /Conformance\2')
