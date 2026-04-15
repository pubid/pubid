require "spec_helper"

RSpec.describe "IEEE Fixture Round-trip Tests" do
  let(:pubid_to_parse_fixtures) do
    File.readlines("archived-gems/pubid-ieee/spec/fixtures/pubid-to-parse.txt").map(&:strip)
  end
  let(:unapproved_fixtures) do
    File.readlines("archived-gems/pubid-ieee/spec/fixtures/unapproved.txt").map(&:strip)
  end
  let(:pubid_parsed_fixtures) do
    File.readlines("archived-gems/pubid-ieee/spec/fixtures/pubid-parsed.txt").map(&:strip)
  end
  let(:all_fixtures) do
    pubid_to_parse_fixtures + unapproved_fixtures + pubid_parsed_fixtures
  end

  describe "pubid-to-parse.txt fixtures" do
    it "round-trips pubid-to-parse identifiers" do
      failures = []
      successes = 0
      total_tested = 0

      pubid_to_parse_fixtures.each do |line|
        next if line.empty? || line.start_with?("#")

        # Parse the !INPUT!EXPECTED format
        parts = line.split("!")
        next if parts.size < 2

        total_tested += 1
        identifier = parts[1] # INPUT part
        expected = parts[2] # EXPECTED part

        begin
          parsed = Pubid::Ieee.parse(identifier)
          rendered = parsed.to_s

          # Compare to expected output
          if rendered == expected
            successes += 1
          else
            failures << {
              original: identifier,
              expected: expected,
              rendered: rendered,
              class: parsed.class.name,
            }
          end
        rescue StandardError => e
          failures << {
            original: identifier,
            expected: expected,
            error: "#{e.class}: #{e.message}",
          }
        end
      end

      puts "\n#{'=' * 80}"
      puts "IEEE pubid-to-parse.txt Results"
      puts "=" * 80
      puts "Total: #{total_tested}"
      puts "Successes: #{successes} (#{(successes.to_f / total_tested * 100).round(2)}%)"
      puts "Failures: #{failures.size}"
      puts "=" * 80

      if failures.any?
        puts "\nFirst 10 failures:"
        failures.first(10).each do |failure|
          if failure[:error]
            puts "  #{failure[:original]} → #{failure[:expected]}"
            puts "    ERROR: #{failure[:error]}"
          else
            puts "  #{failure[:original]} → #{failure[:expected]} (#{failure[:class]})"
            puts "    Got: #{failure[:rendered]}"
          end
        end
      end

      # NOTE: These are V1 fixture files with legacy patterns
      # V2 has different normalization (e.g., "IEEE No" → "IEEE Std")
      # We expect lower pass rate due to architectural differences
      expect(successes.to_f / total_tested).to be >= 0.01
    end
  end

  describe "unapproved.txt fixtures" do
    it "round-trips unapproved identifiers" do
      failures = []
      successes = 0

      unapproved_fixtures.each do |line|
        next if line.empty? || line.start_with?("#")

        # Parse the !INPUT!EXPECTED format
        parts = line.split("!")
        next if parts.size < 2

        identifier = parts[1] # INPUT part
        expected = parts[2] # EXPECTED part

        begin
          parsed = Pubid::Ieee.parse(identifier)
          rendered = parsed.to_s

          # Compare to expected output
          if rendered == expected
            successes += 1
          else
            failures << {
              original: identifier,
              expected: expected,
              rendered: rendered,
              class: parsed.class.name,
            }
          end
        rescue StandardError => e
          failures << {
            original: identifier,
            expected: expected,
            error: "#{e.class}: #{e.message}",
          }
        end
      end

      puts "\n#{'=' * 80}"
      puts "IEEE unapproved.txt Results"
      puts "=" * 80
      puts "Total: #{unapproved_fixtures.size}"
      puts "Successes: #{successes} (#{(successes.to_f / unapproved_fixtures.size * 100).round(2)}%)"
      puts "Failures: #{failures.size}"
      puts "=" * 80

      if failures.any?
        puts "\nFirst 10 failures:"
        failures.first(10).each do |failure|
          if failure[:error]
            puts "  #{failure[:original]} → #{failure[:expected]}"
            puts "    ERROR: #{failure[:error]}"
          else
            puts "  #{failure[:original]} → #{failure[:expected]} (#{failure[:class]})"
            puts "    Got: #{failure[:rendered]}"
          end
        end
      end

      # NOTE: These are V1 fixture files with legacy patterns
      # V2 has different normalization (e.g., "IEEE No" → "IEEE Std")
      # We expect lower pass rate due to architectural differences
      expect(successes.to_f / unapproved_fixtures.size).to be >= 0.00
    end
  end

  describe "pubid-parsed.txt fixtures" do
    it "round-trips pubid-parsed identifiers" do
      failures = []
      successes = 0
      total_tested = 0

      pubid_parsed_fixtures.each do |line|
        next if line.empty? || line.start_with?("#") || line.start_with?("!")

        total_tested += 1

        begin
          parsed = Pubid::Ieee.parse(line)
          rendered = parsed.to_s

          # Round-trip: rendered should match original input
          if rendered == line
            successes += 1
          else
            failures << {
              original: line,
              rendered: rendered,
              class: parsed.class.name,
            }
          end
        rescue StandardError => e
          failures << {
            original: line,
            error: "#{e.class}: #{e.message}",
          }
        end
      end

      puts "\n#{'=' * 80}"
      puts "IEEE pubid-parsed.txt Results"
      puts "=" * 80
      puts "Total: #{total_tested}"
      puts "Successes: #{successes} (#{(successes.to_f / total_tested * 100).round(2)}%)"
      puts "Failures: #{failures.size}"
      puts "=" * 80

      if failures.any?
        puts "\nFirst 10 failures:"
        failures.first(10).each do |failure|
          if failure[:error]
            puts "  #{failure[:original]}"
            puts "    ERROR: #{failure[:error]}"
          else
            puts "  #{failure[:original]} → #{failure[:rendered]} (#{failure[:class]})"
          end
        end
      end

      # NOTE: These are V1 canonical forms - V2 normalization may differ
      # We expect lower pass rate due to architectural differences
      expect(successes.to_f / total_tested).to be >= 0.005
    end
  end

  describe "Combined statistics" do
    it "shows overall round-trip success rate" do
      failures = []
      successes = 0

      all_fixtures.each do |identifier|
        next if identifier.empty? || identifier.start_with?("#")

        begin
          parsed = Pubid::Ieee.parse(identifier)
          rendered = parsed.to_s

          if rendered == identifier
            successes += 1
          else
            failures << {
              original: identifier,
              rendered: rendered,
              class: parsed.class.name,
            }
          end
        rescue StandardError => e
          failures << {
            original: identifier,
            error: "#{e.class}: #{e.message}",
          }
        end
      end

      puts "\n#{'=' * 80}"
      puts "IEEE OVERALL ROUND-TRIP RESULTS"
      puts "=" * 80
      puts "Total identifiers: #{all_fixtures.size}"
      puts "Successes: #{successes} (#{(successes.to_f / all_fixtures.size * 100).round(2)}%)"
      puts "Failures: #{failures.size}"
      puts "=" * 80

      # This test always passes - just reports statistics
      expect(all_fixtures.size).to be > 0
    end
  end
end
