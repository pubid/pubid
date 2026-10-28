# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in pubid.gemspec
gemspec

gem "lutaml-model", github: "lutaml/lutaml-model", branch: "main"
# PG artifact engine (R1 parser swap). The released parsanol carries
# Parsanol::PARG::Artifact. 1.3.112 consolidates the dialect to ONE axis
# named `edition` (ruby#357): the envelope records `edition` ("v1"/"v2")
# in place of the `mode` + `emission` pair, and the grammar header
# keyword is `edition` (`mode` stays a deprecated alias). The artifacts
# here are re-baked at 1.3.112 and carry that field, so the pin rides
# it; the gemspec floor carries the same story for bundles that depend
# on pubid. To use a local clone instead, run:
#   bundle config set local.parsanol ../../parsanol/parsanol-ruby
gem "parsanol", "1.3.112"
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
