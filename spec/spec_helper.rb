# frozen_string_literal: true

# Fixture files contain non-ASCII bytes (e.g. em/en dashes). Without this,
# File.read/readlines default to the process locale (LANG/LC_ALL), which is
# US-ASCII in a locale-less container and raises Encoding::CompatibilityError
# the moment a fixture line with such a byte is read.
Encoding.default_external = Encoding::UTF_8

require_relative "../lib/pubid"

# Load shared test helpers
Dir[File.expand_path("support/*.rb", __dir__)].each do |file|
  require_relative file
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Shared context for all specs
  config.before(:suite) do
  end

  config.after(:suite) do
  end
end
