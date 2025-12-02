require "spec_helper"

RSpec.describe "IEEE Fixture Round-trip Tests" do
  let(:pubid_to_parse_fixtures) { File.readlines("archived-gems/pubid-ieee/spec/fixtures/pubid-to-parse.txt").map(&:strip) }
  let(:unapproved_fixtures) { File.readlines("archived-gems/pubid-ieee/spec/fixtures/unapproved.txt").map(&:strip) }
  let(:pubid_parsed_fixtures) { File.readlines("archived-gems/pubid-ieee/spec/fixtures/pubid-parsed.txt").map(&:strip) }
  let(:all_fixtures) { pubid_to_parse_fixtures + unapproved_fixtures + pubid_parsed_fixtures }

  describe "pubid-to-parse.txt fixtures" do
    it "round-trips pubid-to-parse identifiers" do
      failures = []
      successes = 0

      pubid_to_parse_fixtures.each do |identifier|
        next if identifier.empty? || identifier.start_with?("#")

        begin
          parsed = PubidNew::Ieee.parse(identifier)
          rendered = parsed.to_s

          if rendered == identifier
            successes += 1
          else
            failures << {
              original: identifier,
              rendered: rendered,
              class: parsed.class.name
            }
          end
        rescue => e
          failures << {
            original: identifier,
            error: "#{e.class}: #{e.message}"
          }
        end
      end

      puts "\n" + "=" * 80
      puts "IEEE pubid-to-parse.txt Results"
      puts "=" * 80
      puts "Total: #{pubid_to_parse_fixtures.size}"
      puts "Successes: #{successes} (#{(successes.to_f / pubid_to_parse_fixtures.size * 100).round(2)}%)"
      puts "Failures: #{failures.size}"
      puts "=" * 80

      if failures.any?
        puts "\nFirst 10 failures:"
        failures.first(10).each do |failure|
          if failure[:error]
            puts "  #{failure[:original]}"
            puts "    ERROR: #{failure[:error]}"
          else
            puts "  #{failure[:original]} (#{failure[:class]})"
            puts "    Got: #{failure[:rendered]}"
          end
        end
      end

      expect(successes.to_f / pubid_to_parse_fixtures.size).to be >= 0.80
    end
  end

  describe "unapproved.txt fixtures" do
    it "round-trips unapproved identifiers" do
      failures = []
      successes = 0

      unapproved_fixtures.each do |identifier|
        next if identifier.empty? || identifier.start_with?("#")

        begin
          parsed = PubidNew::Ieee.parse(identifier)
          rendered = parsed.to_s

          if rendered == identifier
            successes += 1
          else
            failures << {
              original: identifier,
              rendered: rendered,
              class: parsed.class.name
            }
          end
        rescue => e
          failures << {
            original: identifier,
            error: "#{e.class}: #{e.message}"
          }
        end
      end

      puts "\n" + "=" * 80
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
            puts "  #{failure[:original]}"
            puts "    ERROR: #{failure[:error]}"
          else
            puts "  #{failure[:original]} (#{failure[:class]})"
            puts "    Got: #{failure[:rendered]}"
          end
        end
      end

      expect(successes.to_f / unapproved_fixtures.size).to be >= 0.80
    end
  end

  describe "pubid-parsed.txt fixtures" do
    it "round-trips pubid-parsed identifiers" do
      failures = []
      successes = 0

      pubid_parsed_fixtures.each do |identifier|
        next if identifier.empty? || identifier.start_with?("#")

        begin
          parsed = PubidNew::Ieee.parse(identifier)
          rendered = parsed.to_s

          if rendered == identifier
            successes += 1
          else
            failures << {
              original: identifier,
              rendered: rendered,
              class: parsed.class.name
            }
          end
        rescue => e
          failures << {
            original: identifier,
            error: "#{e.class}: #{e.message}"
          }
        end
      end

      puts "\n" + "=" * 80
      puts "IEEE pubid-parsed.txt Results"
      puts "=" * 80
      puts "Total: #{pubid_parsed_fixtures.size}"
      puts "Successes: #{successes} (#{(successes.to_f / pubid_parsed_fixtures.size * 100).round(2)}%)"
      puts "Failures: #{failures.size}"
      puts "=" * 80

      if failures.any?
        puts "\nFirst 10 failures:"
        failures.first(10).each do |failure|
          if failure[:error]
            puts "  #{failure[:original]}"
            puts "    ERROR: #{failure[:error]}"
          else
            puts "  #{failure[:original]} (#{failure[:class]})"
            puts "    Got: #{failure[:rendered]}"
          end
        end
      end

      expect(successes.to_f / pubid_parsed_fixtures.size).to be >= 0.80
    end
  end

  describe "Combined statistics" do
    it "shows overall round-trip success rate" do
      failures = []
      successes = 0

      all_fixtures.each do |identifier|
        next if identifier.empty? || identifier.start_with?("#")

        begin
          parsed = PubidNew::Ieee.parse(identifier)
          rendered = parsed.to_s

          if rendered == identifier
            successes += 1
          else
            failures << {
              original: identifier,
              rendered: rendered,
              class: parsed.class.name
            }
          end
        rescue => e
          failures << {
            original: identifier,
            error: "#{e.class}: #{e.message}"
          }
        end
      end

      puts "\n" + "=" * 80
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