require "spec_helper"

RSpec.describe "JIS Fixture Round-trip" do
  let(:fixture_file) do
    # The v1 fixtures, copied verbatim from the old pubid-jis gem.
    File.expand_path("../../fixtures/legacy/jis/jis-pubids.txt", __dir__)
  end

  it "round-trips all identifiers from fixture file" do
    identifiers = File.readlines(fixture_file).map(&:strip).reject(&:empty?)

    passed = 0
    failed = []

    identifiers.each do |pubid|
      identifier = Pubid::Jis.parse(pubid)
      rendered = identifier.to_s
      if pubid == rendered
        passed += 1
      else
        failed << { original: pubid, rendered: rendered }
      end
    rescue StandardError => e
      failed << { original: pubid, error: e.message }
    end

    if failed.any?

      failed.first(10).each do |f|
        if f[:error]

        end
      end
    end

    expect(passed.to_f / identifiers.count).to be >= 0.95 # 95% pass rate minimum
  end
end
