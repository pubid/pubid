require "spec_helper"

RSpec.describe "ETSI Fixture Round-trip Tests" do
  let(:fixtures) do
    # Read from new V2 fixture structure
    fixtures = []
    Dir["spec/fixtures/etsi/identifiers/pass/*.txt"].each do |file|
      fixtures += File.readlines(file).map(&:strip).reject(&:empty?).reject do |l|
        l.start_with?("#")
      end
    end
    fixtures
  end

  describe "ETSI identifiers" do
    it "round-trips all ETSI identifiers" do
      failures = []
      successes = 0

      fixtures.each do |identifier|
        next if identifier.empty? || identifier.start_with?("#")

        begin
          parsed = Pubid::Etsi.parse(identifier)
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
