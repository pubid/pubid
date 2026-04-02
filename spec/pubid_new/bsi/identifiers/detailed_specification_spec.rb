# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Bsi::Identifiers::DetailedSpecification do
  describe "parsing" do
    it "parses N notation format" do
      id = Pubid::Bsi.parse("BS 9074 N002:1974")
      expect(id.class).to eq(described_class)
    end

    it "parses N notation with part" do
      id = Pubid::Bsi.parse("BS 9210 N0009-1:1978")
      expect(id.class).to eq(described_class)
    end

    it "parses C range notation" do
      id = Pubid::Bsi.parse("BS 9300 C155-168:1971")
      expect(id.class).to eq(described_class)
    end
  end

  describe "rendering" do
    it "renders N notation format" do
      id = Pubid::Bsi.parse("BS 9074 N002:1974")
      expect(id.to_s).to eq("BS 9074 N002:1974")
    end

    it "renders N notation with part" do
      id = Pubid::Bsi.parse("BS 9210 N0009-1:1978")
      expect(id.to_s).to eq("BS 9210 N0009-1:1978")
    end

    it "renders C range notation" do
      id = Pubid::Bsi.parse("BS 9300 C155-168:1971")
      expect(id.to_s).to eq("BS 9300 C155-168:1971")
    end

    it "maintains round-trip fidelity" do
      original = "BS 9074 N002:1974"
      id = Pubid::Bsi.parse(original)
      expect(id.to_s).to eq(original)
    end
  end
end
