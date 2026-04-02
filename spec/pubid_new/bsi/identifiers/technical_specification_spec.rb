# frozen_string_literal: true

require_relative "../../../../lib/pubid/bsi"

RSpec.describe Pubid::Bsi::Identifiers::TechnicalSpecification do
  describe "parsing" do
    it "parses TS 3:1993" do
      id = Pubid::Bsi.parse("TS 3:1993")
      expect(id.class).to eq(Pubid::Bsi::Identifiers::TechnicalSpecification)
    end

    it "parses TS 1:1998" do
      id = Pubid::Bsi.parse("TS 1:1998")
      expect(id.class).to eq(Pubid::Bsi::Identifiers::TechnicalSpecification)
    end
  end

  describe "rendering" do
    it "renders TS 3:1993 correctly" do
      id = Pubid::Bsi.parse("TS 3:1993")
      expect(id.to_s).to eq("TS 3:1993")
    end

    it "renders TS 1:1998 correctly" do
      id = Pubid::Bsi.parse("TS 1:1998")
      expect(id.to_s).to eq("TS 1:1998")
    end

    it "maintains round-trip fidelity" do
      original = "TS 3:1993"
      id = Pubid::Bsi.parse(original)
      expect(id.to_s).to eq(original)
    end
  end
end
