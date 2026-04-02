# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Joint Document with Pipe" do
  it "parses ISO 5537|IDF 26" do
    id = Pubid::Iso.parse("ISO 5537|IDF 26")
    expect(id.class).to eq(Pubid::Iso::CombinedIdentifier)
    expect(id.to_s).to eq("ISO 5537 | IDF 26")
  end

  it "parses ISO 17678|IDF 202:2010" do
    id = Pubid::Iso.parse("ISO 17678|IDF 202:2010")
    expect(id.class).to eq(Pubid::Iso::CombinedIdentifier)
    # Note: The ISO identifier doesn't have a year in the input,
    # so it renders without one
    expect(id.to_s).to eq("ISO 17678 | IDF 202:2010")
  end

  it "parses ISO/TS 4985:2023 | IDF/RM 255" do
    id = Pubid::Iso.parse("ISO/TS 4985:2023 | IDF/RM 255")
    expect(id.class).to eq(Pubid::Iso::CombinedIdentifier)
    expect(id.to_s).to eq("ISO/TS 4985:2023 | IDF/RM 255")
  end

  it "parses ISO 4214:2022 | IDF 254:2022" do
    id = Pubid::Iso.parse("ISO 4214:2022 | IDF 254:2022")
    expect(id.class).to eq(Pubid::Iso::CombinedIdentifier)
    expect(id.to_s).to eq("ISO 4214:2022 | IDF 254:2022")
  end

  it "round-trips joint identifier" do
    original = "ISO 5537|IDF 26"
    id = Pubid::Iso.parse(original)
    # Note: The rendered format adds spaces around the pipe
    expect(id.to_s).to eq("ISO 5537 | IDF 26")
  end

  it "has base_identifier and additional_identifiers" do
    id = Pubid::Iso.parse("ISO 5537|IDF 26")
    expect(id.base_identifier).to be_a(Pubid::Iso::Identifier)
    expect(id.additional_identifiers).to be_a(Array)
    expect(id.additional_identifiers.first).to be_a(Pubid::Identifier)
  end

  it "supports ISO copublisher with joint identifier" do
    id = Pubid::Iso.parse("ISO/IEC 8601-1:2019 | IDF/RM 255")
    expect(id.class).to eq(Pubid::Iso::CombinedIdentifier)
    expect(id.to_s).to eq("ISO/IEC 8601-1:2019 | IDF/RM 255")
  end
end
