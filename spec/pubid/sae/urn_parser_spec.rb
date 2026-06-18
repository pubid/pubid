# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/sae"
require_relative "../../support/urn_round_trip"

RSpec.describe Pubid::Sae::UrnParser do
  it_behaves_like "flavor URN round-trip", Pubid::Sae, [
    "SAE J300:2019",
    "SAE AIR500",
    "SAE AMS5000:2020",
    "SAE J3068:2020",
  ]

  describe ".parse" do
    it "parses urn:sae:j:300:2019 into a SAE identifier" do
      id = Pubid::Sae::UrnParser.parse("urn:sae:j:300:2019")
      expect(id.to_s).to eq("SAE J 300:2019")
    end

    it "raises on invalid URN" do
      expect do
        Pubid::Sae::UrnParser.parse("urn:iso:std:iso:9001")
      end.to raise_error(Pubid::UrnParser::Errors::ParseError)
    end
  end
end
