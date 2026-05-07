#!/usr/bin/env ruby
# Test if parser can handle "and" pattern

require_relative "../../../lib/pubid"

# Test with the preprocessed version
input = "IEEE Std 960-1989 and IEEE Std 1177-1989"

# First check if Base.parse handles "and"

begin
  Pubid::Ieee::Identifiers::Base.parse(input)
rescue StandardError
end

# Then test if Parser can handle it directly

begin
  Pubid::Ieee::Parser.parse(input)
rescue StandardError
end

# Also test instance parse (no preprocessing)

begin
  parser = Pubid::Ieee::Parser.new
  parser.parse(input)
rescue StandardError
end
