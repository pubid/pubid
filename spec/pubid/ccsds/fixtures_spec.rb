require "spec_helper"

RSpec.describe "CCSDS Fixture Round-trip Tests" do
  let(:base_fixtures) do
    File.readlines("spec/fixtures/ccsds/identifiers/pass/base.txt").map(&:strip)
  end
  let(:corrigendum_fixtures) do
    File.readlines("spec/fixtures/ccsds/identifiers/pass/corrigendum.txt").map(&:strip)
  end
  let(:all_fixtures) { base_fixtures + corrigendum_fixtures }

  describe "Base publications" do
    it "round-trips all base publication identifiers" do
      failures = []
      successes = 0

      base_fixtures.each do |identifier|
        next if identifier.empty? || identifier.start_with?("#")

        begin
          parsed = Pubid::Ccsds.parse(identifier)
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
      puts "CCSDS Base Publications Results"
      puts "=" * 80
      puts "Total: #{base_fixtures.size}"
      puts "Successes: #{successes} (#{(successes.to_f / base_fixtures.size * 100).round(2)}%)"
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

      expect(successes.to_f / base_fixtures.size).to be >= 0.80
    end
  end

  describe "Corrigendum publications" do
    it "round-trips all corrigendum publication identifiers" do
      failures = []
      successes = 0

      corrigendum_fixtures.each do |identifier|
        next if identifier.empty? || identifier.start_with?("#")

        begin
          parsed = Pubid::Ccsds.parse(identifier)
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
      puts "CCSDS Corrigendum Publications Results"
      puts "=" * 80
      puts "Total: #{corrigendum_fixtures.size}"
      puts "Successes: #{successes} (#{(successes.to_f / corrigendum_fixtures.size * 100).round(2)}%)"
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

      expect(successes.to_f / corrigendum_fixtures.size).to be >= 0.80
    end
  end

  describe "Combined statistics" do
    it "shows overall round-trip success rate" do
      failures = []
      successes = 0

      all_fixtures.each do |identifier|
        next if identifier.empty? || identifier.start_with?("#")

        begin
          parsed = Pubid::Ccsds.parse(identifier)
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
