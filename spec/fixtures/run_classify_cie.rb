#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "classify_fixtures"
require_relative "../../lib/pubid_new/cie"

# Use the standard classifier which creates SUMMARY.txt
classifier = FixturesClassifier.new("cie", verbose: true)
classifier.classify
