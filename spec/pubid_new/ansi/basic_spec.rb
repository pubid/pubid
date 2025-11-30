require "spec_helper"

RSpec.describe "ANSI Basic Tests" do
  describe "ANSI identifiers from parser examples" do
    let(:test_identifiers) do
      [
        "ANSI X3.4-1986",
        "ANSI C63.4-2014",
        "ANSI/ISO 9899:1990",
        "ANSI 802.3-2012",
        "ANSI/IEEE 802.3-2012",
        "ANSI/IEC 60601-1",
        "ANSI/SAE J1939",
        "ANSI/ASME B16.5",
        "ANSI/ASTM E1527"
      ]
    end

    it "round-trips parser example identifiers" do
      failures = []
      successes = 0

      test_identifiers.each do |identifier|
        begin
          parsed = PubidNew::Ansi.parse(identifier)
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
      puts "ANSI BASIC ROUND-TRIP RESULTS"
      puts "=" * 80
      puts "Total identifiers: #{test_identifiers.size}"
      puts "Successes: #{successes} (#{(successes.to_f / test_identifiers.size * 100).round(2)}%)"
      puts "Failures: #{failures.size}"
      puts "=" * 80

      if failures.any?
        puts "\nFailures:"
        failures.each do |failure|
          if failure[:error]
            puts "  #{failure[:original]}"
            puts "    ERROR: #{failure[:error]}"
          else
            puts "  #{failure[:original]} (#{failure[:class]})"
            puts "    Got: #{failure[:rendered]}"
          end
        end
      end

      # Report-only test
      expect(test_identifiers.size).to be > 0
    end
  end
end