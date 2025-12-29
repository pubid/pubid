#!/usr/bin/env ruby
require_relative "lib/pubid_new/ieee/parser"
require_relative "lib/pubid_new/ieee/builder"
require_relative "lib/pubid_new/ieee/identifiers/base"

# Read all identifiers from TODO file
todo_file = "TODO.IEEE-MUST-FIX-IDs.txt"
identifiers = File.readlines(todo_file)
  .reject { |line| line.strip.empty? || line.start_with?("#") }
  .map(&:strip)

categories = Hash.new { |h, k| h[k] = [] }
passing = []
failing = []

identifiers.each do |id|
  begin
    result = PubidNew::Ieee::Identifiers::Base.parse(id)
    passing << id
  rescue => e
    failing << id
    
    # Categorize failures
    case id
    when /&|&/ then categories["Ampersand entities"] << id
    when /Stad\b/ then categories["Typo: Stad"] << id
    when /std /, /IEEE std / then categories["Lowercase std"] << id
    when /\/INT/ then categories["/INT interpretation"] << id
    when /\(TM\)/, /™/ then categories["Trademark symbol"] << id
    when /Conformance/ then categories["Conformance identifiers"] << id
    when /\/Amd\d+/, /\/Cor/ then categories["Amendment/Corrigendum in slash"] << id
    when / and /, / & / then categories["Dual published with 'and' or '&'"] << id
    when /;\s*[A-Z]/ then categories["Semicolon dual published"] << id
    when /\bIRE\b/ then categories["IRE mixed formats"] << id
    when /Edition/ then categories["Edition text"] << id
    when /Preprint/ then categories["Preprint suffix"] << id
    when /Includes\s/, /Supplement/ then categories["Includes/Supplement keywords"] << id
    when /^\d{4}/ then categories["Year-first format"] << id
    else categories["Other"] << id
    end
  end
end

puts "=" * 80
puts "IEEE TODO.IEEE-MUST-FIX-IDs.txt Analysis"
puts "=" * 80
puts "Total identifiers: #{identifiers.length}"
puts "Passing: #{passing.length} (#{(passing.length * 100.0 / identifiers.length).round(1)}%)"
puts "Failing: #{failing.length} (#{(failing.length * 100.0 / identifiers.length).round(1)}%)"
puts
puts "=" * 80
puts "Failure Categories:"
puts "=" * 80
categories.sort_by { |_, v| -v.length }.each do |category, ids|
  puts "\n#{category} (#{ids.length}):"
  ids.first(3).each { |id| puts "  - #{id}" }
  puts "  ..." if ids.length > 3
end
puts
puts "=" * 80
puts "Sample Passing Identifiers:"
puts "=" * 80
passing.first(5).each { |id| puts "  ✓ #{id}" }
puts "  ..." if passing.length > 5
