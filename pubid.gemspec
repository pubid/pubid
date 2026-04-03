require_relative "lib/pubid/version"

Gem::Specification.new do |spec|
  spec.name          = "pubid"
  spec.version       = Pubid::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.homepage      = "https://github.com/metanorma/pubid"
  spec.summary       = "The international publication identifier (PubID) library for Ruby."
  spec.description   = "PubID is a Ruby library for parsing and generating international publication identifiers (PubIDs). It provides a simple and flexible API for working with PubIDs, allowing developers to easily create, manipulate, and validate PubIDs in their applications."
  spec.license       = "BSD-2-Clause"

  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").select do |f|
      f.match(%r{^(lib|exe)/}) || f.match(%r{\.yaml$})
    end
  end
  spec.extra_rdoc_files = %w[README.adoc LICENSE.txt]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = Gem::Requirement.new(">= 3.0.0")

  spec.add_dependency "lutaml-model"
  spec.add_dependency "parslet"
end
