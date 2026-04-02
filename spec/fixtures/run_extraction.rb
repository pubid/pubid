#!/usr/bin/env ruby
# frozen_string_literal: true

# Load all PubID libraries without RSpec
require "bundler/setup"
require_relative "../../lib/pubid"
require_relative "extract_fixtures"

# Run extraction
if ARGV.empty?
  puts "Usage: ruby spec/fixtures/run_extraction.rb <flavor|all> [--verbose]"
  puts
  puts "Examples:"
  puts "  ruby spec/fixtures/run_extraction.rb iso"
  puts "  ruby spec/fixtures/run_extraction.rb all --verbose"
  exit 1
end

flavor_arg = ARGV.first.downcase
verbose = ARGV.include?("--verbose")

if flavor_arg == "all"
  puts "Extracting fixtures for all flavors..."
  puts

  success_count = 0
  FixturesExtractor::FLAVORS.each do |flavor|
    begin
      extractor = FixturesExtractor.new(flavor, verbose: verbose)
      success_count += 1 if extractor.extract
    rescue StandardError => e
      puts "❌ Error extracting #{flavor}: #{e.message}"
      puts e.backtrace.first(3) if verbose
    end
    puts
  end

  puts "=" * 70
  puts "COMPLETE: #{success_count}/#{FixturesExtractor::FLAVORS.size} flavors extracted"
  puts "=" * 70
else
  begin
    extractor = FixturesExtractor.new(flavor_arg, verbose: verbose)
    success = extractor.extract
    exit(success ? 0 : 1)
  rescue StandardError => e
    puts "❌ Error: #{e.message}"
    puts e.backtrace.first(5) if verbose
    exit 1
  end
end
