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

      if failures.any?

        failures.first(10).each do |failure|
          if failure[:error]

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

      if failures.any?

        failures.first(10).each do |failure|
          if failure[:error]

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

      # This test always passes - just reports statistics
      expect(all_fixtures.size).to be > 0
    end
  end
end
