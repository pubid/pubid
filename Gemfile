# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in pubid.gemspec
gemspec

gem "lutaml-model", github: "lutaml/lutaml-model", branch: "main"
# TEMPORARY, remove when lutaml/lutaml-model#767 ships.
#
# json 3.0.0 (released 2026-09-07) made the second argument of JSON.generate
# strict: an unknown key now raises ArgumentError instead of being ignored.
# lutaml-model's StandardAdapter#to_json forwards its OWN options hash - which
# carries lutaml's internal `register:` - straight through as JSON's generator
# options, so every `to_json` on a Lutaml::Model::Serializable now raises
# `ArgumentError: unknown keyword: register`. That is 8 examples in
# spec/pubid/serialization_spec.rb (Iso x2, Bsi, CenCenelec, Jis, Sae, Ansi,
# Idf).
#
# Gemfile.lock is gitignored here, so CI re-resolves on every run and picked
# json 3.0.0 up the day it was published - which is why a build that passed on
# 2026-09-05 fails now with no pubid change behind it.
#
# The pin belongs in the Gemfile, not the gemspec: json is a transitive
# dependency and this is a defect in a dependency's json usage, not a
# constraint pubid should impose on its consumers.
gem "json", "< 3"
# benchmark is used by spec/pubid/iso/performance_spec.rb and is no longer a
# default gem as of Ruby 4.0, so it must be declared explicitly.
gem "benchmark"
gem "nokogiri"
gem "rake"
gem "rspec"
gem "rubocop"
gem "rubocop-performance"
gem "rubocop-rake"
gem "rubocop-rspec"
