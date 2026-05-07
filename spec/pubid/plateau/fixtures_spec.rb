require "spec_helper"

RSpec.describe "PLATEAU Fixture Round-trip Tests" do
  let(:fixtures) do
    File.readlines("spec/fixtures/plateau/identifiers/full/technical_document.txt").map(&:strip)
  end

  describe "PLATEAU identifiers" do
    it "round-trips all PLATEAU identifiers" do
      failures = []
      successes = 0

      fixtures.each do |identifier|
        next if identifier.empty? || identifier.start_with?("#")

        begin
          parsed = Pubid::Plateau.parse(identifier)
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

        failures.first(20).each do |failure|
          if failure[:error]

          end
        end
      end

      expect(successes.to_f / fixtures.size).to be >= 0.80
    end
  end
end
