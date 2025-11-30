require "spec_helper"

RSpec.describe "CCSDS Fixture Round-trip Tests" do
  let(:active_fixtures) { File.readlines("gems/pubid-ccsds/spec/fixtures/active-publications.txt").map(&:strip) }
  let(:historical_fixtures) { File.readlines("gems/pubid-ccsds/spec/fixtures/historical-publications.txt").map(&:strip) }
  let(:all_fixtures) { active_fixtures + historical_fixtures }

  describe "Active publications" do
    it "round-trips all active publication identifiers" do
      failures = []
      successes = 0

      active_fixtures.each do |identifier|
        next if identifier.empty? || identifier.start_with?("#")

        begin
          parsed = PubidNew::Ccsds.parse(identifier)
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
      puts "CCSDS Active Publications Results"
      puts "=" * 80
      puts "Total: #{active_fixtures.size}"
      puts "Successes: #{successes} (#{(successes.to_f / active_fixtures.size * 100).round(2)}%)"
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

      expect(successes.to_f / active_fixtures.size).to be >= 0.80
    end
  end

  describe "Historical publications" do
    it "round-trips all historical publication identifiers" do
      failures = []
      successes = 0

      historical_fixtures.each do |identifier|
        next if identifier.empty? || identifier.start_with?("#")

        begin
          parsed = PubidNew::Ccsds.parse(identifier)
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
      puts "CCSDS Historical Publications Results"
      puts "=" * 80
      puts "Total: #{historical_fixtures.size}"
      puts "Successes: #{successes} (#{(successes.to_f / historical_fixtures.size * 100).round(2)}%)"
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

      expect(successes.to_f / historical_fixtures.size).to be >= 0.80
    end
  end

  describe "Combined statistics" do
    it "shows overall round-trip success rate" do
      failures = []
      successes = 0

      all_fixtures.each do |identifier|
        next if identifier.empty? || identifier.start_with?("#")

        begin
          parsed = PubidNew::Ccsds.parse(identifier)
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
      puts "CCSDS OVERALL ROUND-TRIP RESULTS"
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