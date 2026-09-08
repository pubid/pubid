#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require_relative "classify_fixtures"

# Load Pubid base classes first
require_relative "../../lib/pubid"

# Load every registered flavor. This used to be a hand-maintained list of 19
# `require_relative` lines, so `rake "validation:classify[<flavor>]"` rejected
# the 24 flavors missing from it with "Unknown flavor" — including amca and
# ashrae, whose fixtures therefore could not be regenerated at all.
# `eager_load_flavors!` is the same loader the registry-driven cross-flavor
# specs use, so the classifier and those specs now see the same flavor set.
Pubid.eager_load_flavors!

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
