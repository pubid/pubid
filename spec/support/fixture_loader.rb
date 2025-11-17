# frozen_string_literal: true

module FixtureLoader
  # Load test cases from a fixture file
  #
  # @param flavor [Symbol] The flavor name (e.g., :iso, :iec, :nist)
  # @param filename [String] The fixture filename (e.g., "allrecords.txt")
  # @return [Array<String>] Array of test case strings
  def load_fixture(flavor, filename)
    path = fixture_path(flavor, filename)
    return [] unless File.exist?(path)

    File.readlines(path).map(&:strip).reject(&:empty?)
  end

  # Get fixture file path
  #
  # @param flavor [Symbol] The flavor name
  # @param filename [String] The fixture filename
  # @return [String] Full path to fixture file
  def fixture_path(flavor, filename)
    File.join(__dir__, "..", "fixtures", flavor.to_s, filename)
  end

  # Load fixtures from old gem location
  #
  # @param flavor [Symbol] The flavor name
  # @param filename [String] The fixture filename in gems/pubid-{flavor}/spec/fixtures/
  # @return [Array<String>] Array of test case strings
  def load_gem_fixture(flavor, filename)
    path = File.join(__dir__, "..", "..", "gems", "pubid-#{flavor}", "spec", "fixtures", filename)
    return [] unless File.exist?(path)

    File.readlines(path).map(&:strip).reject(&:empty?)
  end

  # Test result tracker
  class TestResults
    attr_reader :passed, :failed, :errors, :total

    def initialize
      @passed = 0
      @failed = 0
      @errors = []
      @total = 0
    end

    def record_pass
      @passed += 1
      @total += 1
    end

    def record_fail(test_case, expected, actual)
      @failed += 1
      @total += 1
      @errors << { test: test_case, expected: expected, actual: actual, type: :mismatch }
    end

    def record_error(test_case, error)
      @failed += 1
      @total += 1
      @errors << { test: test_case, error: error.message, type: :exception }
    end

    def pass_rate
      return 0.0 if @total.zero?

      (@passed.to_f / @total * 100).round(2)
    end

    def summary
      {
        passed: @passed,
        failed: @failed,
        total: @total,
        pass_rate: pass_rate
      }
    end
  end
end