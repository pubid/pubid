#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require_relative "classify_fixtures"

# Load PubidNew base classes first
require_relative "../../lib/pubid_new/scheme"
require_relative "../../lib/pubid_new/identifier"

# Load all PubID V2 implementations
# Explicitly load all 19 flavors
require_relative "../../lib/pubid_new/iso"
require_relative "../../lib/pubid_new/iec"
require_relative "../../lib/pubid_new/ieee"
require_relative "../../lib/pubid_new/nist"
require_relative "../../lib/pubid_new/jcgm"
require_relative "../../lib/pubid_new/idf"
require_relative "../../lib/pubid_new/oiml"
require_relative "../../lib/pubid_new/astm"
require_relative "../../lib/pubid_new/asme"
require_relative "../../lib/pubid_new/api"
require_relative "../../lib/pubid_new/csa"
require_relative "../../lib/pubid_new/jis"
require_relative "../../lib/pubid_new/etsi"
require_relative "../../lib/pubid_new/ccsds"
require_relative "../../lib/pubid_new/itu"
require_relative "../../lib/pubid_new/plateau"
require_relative "../../lib/pubid_new/ansi"
require_relative "../../lib/pubid_new/cen"
require_relative "../../lib/pubid_new/bsi"

# Get flavor from command line
flavor = ARGV[0]&.downcase

if flavor.nil? || flavor == "all"
  # Classify all registered flavors from the PubidNew::Registry
  PubidNew::Registry.flavor_names.each do |f|
    puts
    begin
      classifier = FixturesClassifier.new(f, verbose: true)
      classifier.classify
    rescue StandardError => e
      puts "⚠️  Skipping #{f.upcase}: #{e.message}"
    end
  end
else
  # Classify specific flavor
  classifier = FixturesClassifier.new(flavor, verbose: true)
  classifier.classify
end
