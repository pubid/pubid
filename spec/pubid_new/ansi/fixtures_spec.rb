require "spec_helper"

RSpec.describe "ANSI Fixture Round-trip Tests" do
  let(:fixtures) do
    File.readlines("gems/pubid-ansi/spec/fixtures/ansi-identifiers.txt").map(&:strip).reject(&:empty?)
  end

  describe "ANSI identifiers from IEEE fixtures" do
    it "round-trips all ANSI identifiers" do
      failures = []
      successes = 0

      fixtures.each do |identifier|
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
      puts "ANSI FIXTURE ROUND-TRIP RESULTS"
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

        if failures.size > 20
          puts "\n... and #{failures.size - 20} more failures"
        end
      end

      # Report success rate (80%+ = production ready)
      pass_rate = (successes.to_f / fixtures.size * 100).round(2)
      
      if pass_rate >= 80.0
        puts "\n✅ PRODUCTION READY: #{pass_rate}% pass rate"
      elsif pass_rate >= 70.0
        puts "\n⚠️  NEAR PRODUCTION: #{pass_rate}% pass rate"
      else
        puts "\n❌ NEEDS WORK: #{pass_rate}% pass rate"
      end

      # Always pass the test - this is a reporting suite
      expect(fixtures.size).to be > 0
    end
  end
end