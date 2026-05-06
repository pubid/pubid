# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Asme::Identifier do
  describe ".parse" do
    it_behaves_like "parse rejection"

    it "parses basic ASME identifier" do
      id = described_class.parse("ASME B16.5-2020")
      expect(id.to_s).to include("ASME")
      expect(id.to_s).to include("B16.5")
    end

    it "parses ASME BPVC identifier" do
      id = described_class.parse("ASME BPVC.IX-2021")
      expect(id.to_s).to include("ASME")
    end

    it "parses ASME BPVC with subdivision" do
      id = described_class.parse("ASME BPVC.III.1.NB-2021")
      expect(id.to_s).to include("ASME")
    end

    it "parses ASME BPVC with case code" do
      id = described_class.parse("ASME BPVC.CC.BPV-2021")
      expect(id.to_s).to include("ASME")
    end

    it "parses ASME standard without year" do
      id = described_class.parse("ASME B16.5")
      expect(id.to_s).to include("ASME")
      expect(id.to_s).to include("B16.5")
    end
  end

  describe "#to_urn" do
    it "generates URN" do
      id = described_class.parse("ASME B16.5-2020")
      expect(id.to_urn).to start_with("urn:asme:")
    end

    it "includes number in URN" do
      id = described_class.parse("ASME B16.5-2020")
      expect(id.to_urn).to include("B16.5")
    end
  end
end
