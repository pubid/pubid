require "spec_helper"

RSpec.describe "IEC V2 Fixtures Tests" do
  let(:fixture_file) do
    File.join(__dir__,
              "../../../archived-gems/pubid-iec/spec/fixtures/iec-pubid.txt")
  end
  let(:fixture_ids) do
    File.readlines(fixture_file).map(&:strip).reject do |line|
      line.empty? || line.start_with?("#")
    end
  end

  describe "IEC fixtures (iec-pubid.txt)" do
    it "has identifiers to test" do
      expect(fixture_ids.count).to be > 0
    end

    it "reports success rate" do
      successes = 0
      failures = []

      fixture_ids.each do |id_str|
        parsed = Pubid::Iec.parse(id_str)
        if parsed.to_s == id_str
          successes += 1
        else
          failures << "Round-trip mismatch: '#{id_str}' -> '#{parsed}'"
        end
      rescue StandardError => e
        failures << "Parse error: '#{id_str}' (#{e.class.name})"
      end

      total = fixture_ids.count
      pass_rate = (successes.to_f / total * 100).round(2)

      if failures.any?

        failures.first(30).each { |f| }
      end

      expect(pass_rate).to be >= 80.0,
                           "Expected at least 80% pass rate on REAL fixtures, got #{pass_rate}%"
    end
  end
end
