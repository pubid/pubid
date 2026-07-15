# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Pubid::Ecma URN handling" do
  describe "UrnGenerator#generate" do
    {
      "ECMA-411" => "urn:ecma:411",
      "ECMA-418-1" => "urn:ecma:418:part-1",
      "ECMA-418-2" => "urn:ecma:418:part-2",
      "ECMA TR/101" => "urn:ecma:tr:101",
      "ECMA MEM/1970" => "urn:ecma:mem:1970",
    }.each do |input, urn|
      it "renders #{input.inspect} as #{urn.inspect}" do
        expect(Pubid::Ecma.parse(input).to_urn).to eq(urn)
      end
    end
  end

  describe "UrnParser#parse_urn (round-trips the generator)" do
    [
      "ECMA-411",
      "ECMA-418-1",
      "ECMA-418-2",
      "ECMA TR/101",
      "ECMA MEM/1970",
    ].each do |input|
      it "round-trips #{input.inspect} via URN" do
        urn = Pubid::Ecma.parse(input).to_urn
        expect(Pubid::Ecma::UrnParser.parse(urn).to_s).to eq(input)
      end
    end

    it "is reachable through global URN dispatch" do
      urn = Pubid::Ecma.parse("ECMA TR/101").to_urn
      expect(Pubid.parse(urn).to_urn).to eq(urn)
    end
  end
end
