# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in pubid.gemspec
gemspec

gem "lutaml-model", github: "lutaml/lutaml-model", branch: "main"
# PG artifact engine (R1 parser swap). The flip condition the old comment
# waited for is met: the released parsanol carries Parsanol::PARG::Artifact.
# 1.3.110 additionally made the v2 named-tree dialect the default, which
# broke plain references ("Unknown parameter type: space"; per-atom digit
# runs) — parsanol#352. 1.3.111 shipped the trivia exemption
# (parsanol#355) and the artifacts here are re-baked at it (emission-2
# trees, parameter-shaped), so the pin rides 1.3.111; the gemspec floor
# carries the same story for bundles that depend on pubid. To use a local
# clone instead, run:
#   bundle config set local.parsanol ../../parsanol/parsanol-ruby
gem "parsanol", "1.3.111"
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
