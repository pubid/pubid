#!/usr/bin/env ruby
require_relative 'lib/pubid_new'

fixtures_dir = 'spec/fixtures/iso'
failures = []
passed = 0
total = 0

Dir.glob("#{fixtures_dir}/*.txt").sort.each do |file|
  File.readlines(file).each do |line|
    line = line.strip
    next if line.empty? || line.start_with?('#')
    
    total += 1
    begin
      identifier = PubidNew::Iso.parse(line)
      rendered = identifier.to_s
      if line == rendered
        passed += 1
      else
        failures << {
          input: line,
          output: rendered,
          type: :mismatch,
          file: File.basename(file)
        }
      end
    rescue => e
      failures << {
        input: line,
        error: e.message.split("\n").first,
        type: :error,
        file: File.basename(file)
      }
    end
    
    # Progress indicator every 500 tests
    if total % 500 == 0
      puts "Tested #{total} cases... (#{passed} passed, #{failures.size} failed)"
    end
  end
end

puts "\n" + "="*80
puts "ISO PubID v2 - Complete Test Results"
puts "="*80
puts "Total: #{total}"
puts "Passed: #{passed}"
puts "Failed: #{failures.size}"
puts "Pass Rate: #{(passed.to_f/total*100).round(2)}%"
puts "="*80

if failures.any?
  puts "\nFAILURES (#{failures.size}):"
  puts "="*80
  failures.each_with_index do |f, idx|
    puts "\n#{idx+1}. [#{f[:file]}]"
    puts "   Input:  #{f[:input]}"
    if f[:type] == :mismatch
      puts "   Output: #{f[:output]}"
    else
      puts "   Error:  #{f[:error]}"
    end
  end
  
  # Write failures to file
  File.write('iso_failures.txt', failures.map { |f| 
    if f[:type] == :mismatch
      "#{f[:input]} => #{f[:output]} [#{f[:file]}]"
    else
      "#{f[:input]} => ERROR: #{f[:error]} [#{f[:file]}]"
    end
  }.join("\n"))
  puts "\n" + "="*80
  puts "Failures written to: iso_failures.txt"
end