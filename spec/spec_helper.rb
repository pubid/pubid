# frozen_string_literal: true

require_relative "../lib/pubid_new"

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
    puts "PubID v2 Test Suite - Testing all flavors"
    puts "=" * 60
  end

  config.after(:suite) do
    puts "=" * 60
    puts "Test suite completed"
  end
end
