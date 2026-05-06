# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Sae::Identifier do
  describe ".parse" do
    it_behaves_like "parse rejection"

    it "parses basic SAE J standard" do
      id = described_class.parse("SAE J300")
      expect(id.to_s).to eq("SAE J 300")
    end

    it "parses SAE J with year" do
      id = described_class.parse("SAE J300:2019")
      expect(id.to_s).to eq("SAE J 300:2019")
    end

    it "parses SAE J with letter suffix" do
      id = described_class.parse("SAE J790F")
      expect(id.to_s).to eq("SAE J 790F")
    end

    it "parses SAE AMS aerospace material spec" do
      id = described_class.parse("SAE AMS2404")
      expect(id.to_s).to include("AMS")
      expect(id.to_s).to include("2404")
    end

    it "parses SAE AIR aerospace information report" do
      id = described_class.parse("SAE AIR1936")
      expect(id.to_s).to include("AIR")
    end

    it "parses SAE ARP aerospace recommended practice" do
      id = described_class.parse("SAE ARP4754A")
      expect(id.to_s).to include("ARP")
    end

    it "parses SAE AS aerospace standard" do
      id = described_class.parse("SAE AS5553")
      expect(id.to_s).to include("AS")
    end
  end

  describe "#to_urn" do
    it "generates URN" do
      id = described_class.parse("SAE J300:2019")
      expect(id.to_urn).to start_with("urn:sae:")
    end

    it "includes type in URN" do
      id = described_class.parse("SAE J300:2019")
      expect(id.to_urn).to include(":j:")
    end
  end
end
