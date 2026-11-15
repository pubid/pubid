# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in pubid.gemspec
gemspec

gem "lutaml-model", github: "lutaml/lutaml-model", branch: "main"
# PG artifact engine (R1 parser swap). The released parsanol carries
# Parsanol::PARG::Artifact. The dialect consolidates to ONE axis named
# `edition` (ruby#357): the envelope records `edition` ("v1"/"v2") and
# the grammar header keyword is `edition` (`mode` stays a deprecated
# alias). The engine graduated to the engine-linked line (parsanol-rs#519):
# the gemspec floor is ~> 1.5.0 and the dev pin rides the published
# 1.5.0.0 runtime gem. To use a
# local clone instead, run:
#   bundle config set local.parsanol ../../parsanol/parsanol-ruby
gem "parsanol", "1.5.0.0"
gem "json_schemer" # testsuite schema validation (tools/validate_schema.rb)
# benchmark is used by spec/pubid/iso/performance_spec.rb and is no longer a
# default gem as of Ruby 4.0, so it must be declared explicitly.
gem "benchmark"
gem "nokogiri"
gem "rake"
gem "rspec"
gem "yard" # docs:api_reference — the generated API reference (pubid#577)
gem "json_schemer"
gem "rubocop"
gem "rubocop-performance"
gem "rubocop-rake"
gem "rubocop-rspec"
