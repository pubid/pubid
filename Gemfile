# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in pubid.gemspec
gemspec

gem "lutaml-model", github: "lutaml/lutaml-model", branch: "main"
# PG artifact engine (R1 parser swap). The flip condition the old comment
# waited for is met: the released parsanol carries Parsanol::PARG::Artifact.
# 1.3.110 additionally made the v2 named-tree dialect the default — every
# uncaptured rule reference surfaces as a capture, so plain references
# break two ways ("Unknown parameter type: space" on the whitespace glue;
# digit runs parse as per-atom lists) — parsanol#352. Pin the last
# classic-dialect release until the v2 migration lands; pubid.gemspec
# carries the same cap ("< 1.3.110") for bundles that depend on pubid.
# To use a local clone instead, run:
#   bundle config set local.parsanol ../../parsanol/parsanol-ruby
gem "parsanol", "1.3.109"
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
