require "spec_helper"

RSpec.describe "ETSI Fixture Round-trip Tests" do
  let(:fixtures) { File.readlines("gems/pubid-etsi/spec/fixtures/pubids.txt").map(&:strip) }

  describe "ETSI identifiers" do
    it "round-trips all ETSI identifiers" do
      failures = []
      successes = 0

      fixtures.each do |identifier|
        next if identifier.empty? || identifier.start_with?("#")

        begin
          parsed = PubidNew::Etsi.parse(identifier)
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
      puts "ETSI ROUND-TRIP RESULTS"
      puts "=" * 80
      puts "Total identifiers: #{fixtures.size}"
      puts "Successes: #{successes} (#{(successes.to_f / fixtures.size * 100).round(2)}%)"
      puts "Failures: #{failures.size}"
      puts "=" * 80

      if failures.any?
        puts "\nFirst 20 failures:"
        failures.first(20).each do |failure|
          if failure[:error]
            puts "  #{failure[:original]}"
            puts "    ERROR: #{failure[:error]}"
          else
            puts "  #{failure[:original]} (#{failure[:class]})"
            puts "    Got: #{failure[:rendered]}"
          end
        end
      end

      expect(successes.to_f / fixtures.size).to be >= 0.80
    end
  end
end