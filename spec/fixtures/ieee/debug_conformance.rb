#!/usr/bin/env ruby
# Debug test for conformance patterns

require_relative "../../../lib/pubid"

test_case = "IEEE Std 802.16/Conformance01-2003"

# Try with instance method (no preprocessing)
begin
  parser = Pubid::Ieee::Parser.new
  parser.parse(test_case)
rescue Parslet::ParseFailed
end

# Try with class method (with preprocessing)

begin
  parser = Pubid::Ieee::Parser
  parser.parse(test_case)
rescue Parslet::ParseFailed
end

# Now try the full parse

begin
  Pubid::Ieee.parse(test_case)
rescue Parslet::ParseFailed
rescue StandardError
end
