#!/usr/bin/env ruby
require_relative "lib/pubid_new/ieee/parser"
require_relative "lib/pubid_new/ieee/builder"
require_relative "lib/pubid_new/ieee/identifiers/base"

# Test sample identifiers from TODO.IEEE-MUST-FIX-IDs.txt
test_cases = [
  # Ampersand entities
  "ANSI/IEEE Std 500-1984 P&V",
  "ANSI/IEEE Std 500-1984 P&amp;V",
  
  # Dual published
  "AIEE No 18-1934 (ASA C55 1934)",
  "IEEE Std 120-1955; ASME PTC 19.6-1955",
  "IEEE Std 802.10e-1993 and IEEE std 802.10f-1993",
  
  # IRE mixed
  "IEEE Std 59 IRE 12, S1",
  
  # Typos
  "IEEE Stad 204-1961",
  
  # INT editions
  "IEEE Std 1003.1/2003.1/INT March 1994 Edition",
  
  # Conformance
  "IEEE Std 1904.1(TM)/Conformance02-2014 (Conformance to IEEE Std 1904.1-2013)",
  
  # A.I.E.E. format
  "A.I.E.E. No. 15 May-1928",
]

test_cases.each_with_index do |id, i|
  begin
    result = PubidNew::Ieee::Identifiers::Base.parse(id)
    puts "✓ #{i+1}. PASS: #{id}"
    puts "   => #{result.to_s}"
  rescue => e
    puts "✗ #{i+1}. FAIL: #{id}"
    puts "   Error: #{e.class}: #{e.message.split("\n").first}"
  end
  puts
end
