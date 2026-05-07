#!/usr/bin/env ruby
# frozen_string_literal: true

# Load all PubID libraries without RSpec
require "bundler/setup"
require_relative "../../lib/pubid"
require_relative "extract_fixtures"

# Run extraction
if ARGV.empty?
  
  
  
  
  
  exit 1
end

flavor_arg = ARGV.first.downcase
verbose = ARGV.include?("--verbose")

if flavor_arg == "all"
  
  

  success_count = 0
  FixturesExtractor::FLAVORS.each do |flavor|
    begin
      extractor = FixturesExtractor.new(flavor, verbose: verbose)
      success_count += 1 if extractor.extract
    rescue StandardError => e
      
       if verbose
    end
    
  end

  
  
  
else
  begin
    extractor = FixturesExtractor.new(flavor_arg, verbose: verbose)
    success = extractor.extract
    exit(success ? 0 : 1)
  rescue StandardError => e
    
     if verbose
    exit 1
  end
end
