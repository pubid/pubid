#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require_relative "lib/pubid_new/nist/parser"
require_relative "lib/pubid_new/nist/builder"
require_relative "lib/pubid_new/nist/scheme"
require_relative "lib/pubid_new/nist/identifiers/base"
require_relative "lib/pubid_new/nist/identifiers/special_publication"
require_relative "lib/pubid_new/nist/identifiers/federal_information_processing_standards"
require_relative "lib/pubid_new/nist/identifiers/internal_report"
require_relative "lib/pubid_new/nist/identifiers/handbook"
require_relative "lib/pubid_new/nist/identifiers/technical_note"

# Simple parse function to avoid Registry
def parse_nist(identifier)
  parsed = PubidNew::Nist::Parser.parse(identifier)
  builder = PubidNew::Nist::Builder.new(PubidNew::Nist::Scheme)
  builder.build(parsed)
end

# Read TODO patterns
todo_patterns = File.readlines("TODO.NIST-MUST-FIX.md")
  .grep_v(/^#|^$/)
  .map(&:strip)
  .reject(&:empty?)

puts "Testing #{todo_patterns.size} NIST TODO patterns..."
puts "=" * 80

passing = []
failing = []

todo_patterns.each do |pattern|
  begin
    result = parse_nist(pattern)
    passing << pattern
    puts "✅ #{pattern}"
  rescue => e
    failing << pattern
    puts "❌ #{pattern}"
    puts "   Error: #{e.message.split("\n").first}"
  end
end

puts "\n" + "=" * 80
puts "RESULTS:"
puts "-" * 80
puts "Passing: #{passing.size}/#{todo_patterns.size} (#{(passing.size.to_f / todo_patterns.size * 100).round(1)}%)"
puts "Failing: #{failing.size}/#{todo_patterns.size} (#{(failing.size.to_f / todo_patterns.size * 100).round(1)}%)"

if failing.any?
  puts "\n" + "=" * 80
  puts "FAILING PATTERNS (#{failing.size}):"
  puts "-" * 80
  failing.each { |p| puts "  #{p}" }
end

puts "\n" + "=" * 80
puts "PATTERN CATEGORIES:"
puts "-" * 80

categories = {
  "Volume ranges (v2a-l, v2m-z)" => failing.grep(/v\d+[a-z]-[a-z]/),
  "Dotted versions (v1.1, v1.0.2)" => failing.grep(/v\d+\.\d+/),
  "Version without dots (ver2, ver2v1)" => failing.grep(/ver\d+/),
  "Revision with year (rev2013)" => failing.grep(/rev\d{4}/),
  "Revision with letter (r1a, ra)" => failing.grep(/r\d*[a-z]/),
  "Complex parts (p1adde1, Pt3r1)" => failing.grep(/[Pp]t?\d+add|Pt\d+r\d+/),
  "Update patterns (-upd, /upd)" => failing.grep(/upd/),
  "Roman numerals (I-2.0, II-1.0)" => failing.grep(/-[IVX]+-/),
  "Special series (AMS, VTS, LCIRC, RPT)" => failing.grep(/AMS|VTS|LCIRC|RPT/),
  "Lowercase input" => failing.grep(/^nist/i).reject { |p| p =~ /^NIST/ }
}

categories.each do |name, patterns|
  unless patterns.empty?
    puts "\n#{name}: #{patterns.size} failing"
    patterns.each { |p| puts "  - #{p}" }
  end
end