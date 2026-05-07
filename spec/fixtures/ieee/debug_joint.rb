#!/usr/bin/env ruby
# Debug joint standard parsing

require_relative "../../../lib/pubid"

input = "IEEE Std 960-1989, Std 1177-1989"

# Test preprocessing
input.gsub(/(\d{4}),\s+Std\s/, '\1 and IEEE Std ')

# Try parsing
begin
  Pubid::Ieee.parse(input)
rescue StandardError
end
