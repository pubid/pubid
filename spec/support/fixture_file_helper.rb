# frozen_string_literal: true

# Shared helper module for reading fixture files in tests
# Handles blank lines and comments consistently across all fixture tests
module FixtureFileHelper
  # Read identifiers from a fixture file, filtering blank lines and comments
  # @param file_path [String] Path to the fixture file
  # @return [Array<String>] Array of identifier strings
  def read_fixture_file(file_path)
    File.readlines(file_path).map(&:strip).reject do |line|
      line.empty? || line.start_with?("#")
    end
  end

  # Find all fixture files in a directory
  # @param dir_path [String] Path to the fixtures directory
  # @return [Array<String>] Array of file paths
  def find_fixture_files(dir_path)
    Dir.glob(File.join(dir_path, "*.txt"))
  end

  # Test round-trip parsing for a list of identifiers
  # @param identifiers [Array<String>] List of identifier strings
  # @param parser [Object] Parser object with .parse method
  # @return [Hash] Results with :successes, :failures, :total, :pass_rate
  def test_round_trip(identifiers, parser)
    failures = []
    successes = 0

    identifiers.each do |id_str|
      parsed = parser.parse(id_str)
      rendered = parsed.to_s

      if rendered == id_str
        successes += 1
      else
        failures << { original: id_str, rendered: rendered,
                      type: "mismatch" }
      end
    rescue StandardError => e
      failures << { original: id_str, error: "#{e.class}: #{e.message}",
                    type: "parse_error" }
    end

    total = identifiers.count
    pass_rate = total.positive? ? (successes.to_f / total * 100).round(2) : 0

    { successes: successes, failures: failures, total: total,
      pass_rate: pass_rate }
  end
end
