require_relative "lib/pubid/version"

Gem::Specification.new do |spec|
  spec.name          = "pubid"
  spec.version       = Pubid::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.homepage      = "https://github.com/pubid/pubid"
  spec.summary       = "The international publication identifier (PubID) library for Ruby."
  spec.description   = "PubID is a Ruby library for parsing and generating international publication identifiers (PubIDs). It provides a simple and flexible API for working with PubIDs, allowing developers to easily create, manipulate, and validate PubIDs in their applications."
  spec.license       = "BSD-2-Clause"
  spec.metadata["changelog_uri"] = "https://github.com/pubid/pubid/releases"
  spec.metadata["documentation_uri"] = "https://rubydoc.info/gems/pubid"

  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").select do |f|
      f.match(%r{^(lib|exe|data)/}) || f.match(%r{\.yaml$})
    end
  end
  spec.extra_rdoc_files = %w[README.adoc LICENSE.txt]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = Gem::Requirement.new(">= 3.0.0")

  spec.add_dependency "lutaml-model", "~> 0.8"
  # The PARG artifact runtime: the baked flavor grammars parse through
  # Parsanol::PARG (the Gemfile's git pin is the dev source; published
  # gems resolve this from rubygems). 1.3.57 is the first release whose
  # extension builds against the 0.10 engine line.
  # Pessimistic on 1.3.122: 1.3.122 restores the flat occurrence pairing
  # the shipped artifacts are written against (1.3.121's per-instance
  # pairing, ruby#381, materialized phantom array-group rows), and
  # `edition` records "v1"/"v2" in the artifact envelope — 1.3.114
  # introduced the field. 1.4 is the next minor line.
  spec.add_dependency "parsanol", "~> 1.3.122"
  # Bundled gem required by lib code: benchmark in lib/tasks/benchmark.rake (metanorma/metanorma#669)
  spec.add_dependency "benchmark"
  spec.metadata["rubygems_mfa_required"] = "true"
end
