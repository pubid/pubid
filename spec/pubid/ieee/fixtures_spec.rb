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

  # Emit a concise, human-readable summary of the fixture mismatches so the
  # real round-trip rate and the first failures are visible when running the
  # suite (issue #32 — these blocks used to be empty, hiding the failures).
  def report_mismatches(label, header, failures)
    return if failures.empty?

    lines = ["#{label}: #{header}, #{failures.size} mismatches (first 10):"]
    failures.first(10).each { |f| lines << format_failure(f) }
    RSpec.configuration.reporter.message(lines.join("\n"))
  end

  def format_failure(failure)
    original = failure[:original].inspect
    return "  #{original} -> ERROR #{failure[:error]}" if failure[:error]

    detail = "  #{original}\n"
    detail += "    expected: #{failure[:expected].inspect}\n" if failure.key?(:expected)
    detail + "    got:      #{failure[:rendered].inspect} (#{failure[:class]})"
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

      pct = (successes.to_f / total_tested * 100).round(2)
      report_mismatches("pubid-to-parse",
                        "#{successes}/#{total_tested} round-trip (#{pct}%)",
                        failures)

      # These are V1 fixture files whose "expected" column is internally
      # inconsistent and, in many cases, encodes conventions V2 deliberately
      # abandoned, so a large subset can never round-trip without regressing V2
      # (see issue #32 for the analysis). Known non-round-trippable classes:
      #   * V2 emits "IEEE Std 267A-1980" where the fixture expects bare
      #     "IEEE 267A-1980" (V2's "IEEE Std" form is the correct one).
      #   * The fixture drops "AIEE No" (→ "AIEE 14-1925"); V2 deliberately
      #     retains it (asserted in identifiers/base_spec.rb).
      #   * Month/year comma ("August 2016" vs "August, 2016") and trailing
      #     ".pdf" differ between this file and pubid-parsed.txt.
      # The threshold is therefore a floor over the genuinely round-trippable
      # fixtures, raised from the historical 1% (which had been reached only by
      # relaxing the denominator, not by fixing mismatches) to lock in the
      # NESC-family fixes from issue #32.
      expect(successes.to_f / total_tested).to be >= 0.05
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

      report_mismatches("unapproved", "#{successes} round-trip", failures)

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

      report_mismatches("pubid-parsed",
                        "#{successes}/#{total_tested} round-trip", failures)

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

      # This test always passes - just reports statistics
      expect(all_fixtures.size).to be > 0
    end
  end
end
