#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../lib/pubid_new/cie"

# Read all CIE fixtures
fixtures = []
Dir.glob("cie/full/*.txt").each do |file|
  File.readlines(file).each do |line|
    line = line.strip
    next if line.empty? || line.start_with?("#")
    fixtures << line
  end
end

# Classify
passed = []
failed = []

fixtures.each do |fixture|
  begin
    id = PubidNew::Cie.parse(fixture)
    rendered = id.to_s
    if rendered == fixture
      passed << fixture
    else
      failed << "!#{fixture}!#{rendered}"
    end
  rescue => e
    failed << "##{fixture}# #{e.class}: #{e.message.split('at line').first.strip}"
  end
end

# Create directories
require "fileutils"
FileUtils.mkdir_p("cie/identifiers/pass")
FileUtils.mkdir_p("cie/identifiers/fail")

# Write pass file
File.write("cie/identifiers/pass/all.txt", passed.join("\n"))

# Write fail file  
File.write("cie/identifiers/fail/all.txt", failed.join("\n"))

# Summary
puts "=" * 70
puts "CIE Classification Complete"
puts "=" * 70
puts "Total: #{fixtures.length}"
puts "Pass:  #{passed.length} (#{(passed.length.to_f/fixtures.length*100).round(2)}%)"
puts "Fail:  #{failed.length} (#{(failed.length.to_f/fixtures.length*100).round(2)}%)"
puts "=" * 70
