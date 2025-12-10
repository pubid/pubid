#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require_relative "classify_fixtures"

# Load PubidNew base classes first
require_relative "../../lib/pubid_new/scheme"
require_relative "../../lib/pubid_new/identifier"

# Load all PubID V2 implementations
require_relative "../../lib/pubid_new/iso"
require_relative "../../lib/pubid_new/iec"
require_relative "../../lib/pubid_new/ieee"
require_relative "../../lib/pubid_new/nist"
require_relative "../../lib/pubid_new/jcgm"

# Get flavor from command line
flavor = ARGV[0]&.downcase

if flavor.nil? || flavor == "all"
  # Classify all flavors with V2 implementations
  %w[iso iec ieee nist jcgm].each do |f|
    puts
    classifier = FixturesClassifier.new(f, verbose: true)
    classifier.classify
  end
else
  # Classify specific flavor
  classifier = FixturesClassifier.new(flavor, verbose: true)
  classifier.classify
end