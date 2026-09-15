# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/pubid/evs"

RSpec.describe "EVS Integration Tests" do
  # [input, expected_output (if different from input)]
  test_cases = [
    ["EVS-EN 18216:2026"],
    ["EVS-EN 18219:2026"],
    ["EVS-EN 18220:2026"],
    ["EVS-EN 18221:2026"],
    ["EVS-EN 18222:2026"],
    ["EVS-EN 18223:2026"],
    ["EVS-EN ISO 14001:2026"],
    ["EVS-EN ISO 9001:2015/A1:2024"],
    ["EVS-EN ISO/IEC 27017:2026"],
    ["EVS-EN ISO/IEC 27701:2025"],

    # Printed space form (kept verbatim on render)
    ["EVS EN 18216:2026"],
  ].freeze

  it "parses and renders every test case" do
    test_cases.each do |input, expected|
      parsed = Pubid.parse(input)
      expect(parsed).to be_a(Pubid::Evs::Identifiers::NationalAdoption),
                        "expected NationalAdoption for #{input.inspect}"
      expect(parsed.to_s).to eq(expected || input), "for #{input.inspect}"
    end
  end

  it "routes through the registry by prefix" do
    expect(Pubid::Registry.registered?(:evs)).to be(true)
    expect(Pubid::Registry.get(:evs)).to eq(Pubid::Evs)
  end

  it "does not claim bare CEN identifiers" do
    expect(Pubid.parse("EN 18216:2026"))
      .to be_a(Pubid::CenCenelec::Identifiers::EuropeanNorm)
  end
end
