# frozen_string_literal: true

require "spec_helper"

RSpec.describe "IECEE TRF semicolon normalization — issue #239" do
  # IEC's source data uses a semicolon (;) where OD-010-1 prescribes an
  # ampersand (&) for combining test portions. data/iec/update_codes.yaml
  # normalizes the known case before parsing.

  it "normalizes IECEE TRF 60335-2-4;7F:2012 to the ampersand form" do
    parsed = Pubid::Iec.parse("IECEE TRF 60335-2-4;7F:2012")
    expect(parsed.to_s).to eq("IECEE TRF 60335-2-4&7F:2012")
  end

  it "parses the canonical ampersand form unchanged" do
    parsed = Pubid::Iec.parse("IECEE TRF 60335-2-4&7F:2012")
    expect(parsed.to_s).to eq("IECEE TRF 60335-2-4&7F:2012")
  end

  it "applies the same result via the class-level parse" do
    via_module = Pubid::Iec.parse("IECEE TRF 60335-2-4;7F:2012")
    via_class = Pubid::Iec::Identifier.parse("IECEE TRF 60335-2-4;7F:2012")
    expect(via_module.to_s).to eq(via_class.to_s)
  end
end
