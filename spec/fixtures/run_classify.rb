#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require_relative "classify_fixtures"

# Load Pubid base classes first
require_relative "../../lib/pubid"

# Load all PubID V2 implementations
# Explicitly load all 19 flavors
require_relative "../../lib/pubid/iso"
require_relative "../../lib/pubid/iec"
require_relative "../../lib/pubid/ieee"
require_relative "../../lib/pubid/nist"
require_relative "../../lib/pubid/jcgm"
require_relative "../../lib/pubid/idf"
require_relative "../../lib/pubid/oiml"
require_relative "../../lib/pubid/astm"
require_relative "../../lib/pubid/asme"
require_relative "../../lib/pubid/api"
require_relative "../../lib/pubid/csa"
require_relative "../../lib/pubid/jis"
require_relative "../../lib/pubid/etsi"
require_relative "../../lib/pubid/ccsds"
require_relative "../../lib/pubid/itu"
require_relative "../../lib/pubid/plateau"
require_relative "../../lib/pubid/ansi"
require_relative "../../lib/pubid/cen_cenelec"
require_relative "../../lib/pubid/bsi"

# Get flavor from command line
flavor = ARGV[0]&.downcase

if flavor.nil? || flavor == "all"
  # Classify all registered flavors from the Pubid::Registry
  Pubid::Registry.flavor_names.each do |f|
    classifier = FixturesClassifier.new(f, verbose: true)
    classifier.classify
  rescue StandardError
  end
else
  # Classify specific flavor
  classifier = FixturesClassifier.new(flavor, verbose: true)
  classifier.classify
end
