# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Itu::Scheme do
  describe ".model_class" do
    it "returns the Model class" do
      expect(described_class.model_class).to eq(PubidNew::Itu::Model)
    end
  end

  describe ".transform" do
    it "transforms parsed data with sector to model attributes" do
      parsed = { sector: "T", t_content: { numbering: [{ number: "123" }] } }
      result = described_class.transform(parsed)
      expect(result[:sector]).to eq("T")
      expect(result[:number]).to eq("123")
    end

    it "transforms parsed data without sector" do
      parsed = { r_content: { numbering: { number: "456" } } }
      result = described_class.transform(parsed)
      expect(result[:number]).to eq("456")
    end

    it "handles study group series" do
      parsed = {
        sector: "Q",
        t_content: {
          numbering: [{ number: "10" }],
          series: { sg_number: "16" }
        }
      }
      result = described_class.transform(parsed)
      expect(result[:series]).to eq("SG16")
    end

    it "handles subseries numbering" do
      parsed = {
        sector: "T",
        t_content: {
          numbering: [
            { number: "81" },
            { subseries: "06" }
          ]
        }
      }
      result = described_class.transform(parsed)
      expect(result[:number]).to eq("81")
      expect(result[:subseries]).to eq("06")
    end
  end

  describe "ATTRIBUTE_MAPPINGS" do
    it "defines attribute mappings" do
      expect(described_class::ATTRIBUTE_MAPPINGS).to be_a(Hash)
      expect(described_class::ATTRIBUTE_MAPPINGS[:sector]).to eq(:sector)
      expect(described_class::ATTRIBUTE_MAPPINGS[:number]).to eq(:number)
    end
  end
end
