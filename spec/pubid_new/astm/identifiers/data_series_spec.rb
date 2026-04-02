# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Astm::Identifiers::DataSeries do
  # ========================================
  # Data Series (33 IDs, 11%)
  # ========================================
  describe "parses simple data series" do
    subject { "ASTM DS4B-EB" }
    let(:parsed) { PubidNew::Astm.parse(subject) }

    it "parses" do
      expect(parsed).to be_a(described_class)
      expect(parsed.code.number).to eq("4")
      expect(parsed.code.suffix).to eq("B")
      expect(parsed.to_s).to eq("ASTM DS4B-EB")
    end
  end

  describe "parses data series with subseries" do
    subject { "ASTM DS7-S1-EB" }
    let(:parsed) { PubidNew::Astm.parse(subject) }

    it "parses" do
      expect(parsed).to be_a(described_class)
      expect(parsed.code.number).to eq("7")
      expect(parsed.code.subseries).to eq("1")
      expect(parsed.to_s).to eq("ASTM DS7-S1-EB")
    end
  end

  describe "parses data series with HOL suffix" do
    subject { "ASTM DS51HOL-EB" }
    let(:parsed) { PubidNew::Astm.parse(subject) }

    it "parses" do
      expect(parsed).to be_a(described_class)
      expect(parsed.code.number).to eq("51")
      expect(parsed.hol_suffix).to eq(true)
      expect(parsed.to_s).to eq("ASTM DS51HOL-EB")
    end
  end
end
