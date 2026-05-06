# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Amca::Identifier do
  describe ".parse" do
    it_behaves_like "parse rejection"

    it "parses AMCA publication" do
      id = described_class.parse("AMCA Publication 311-16")
      expect(id.to_s).to include("AMCA")
      expect(id.to_s).to include("311")
    end

    it "parses AMCA standard" do
      id = described_class.parse("AMCA 210-16")
      expect(id.to_s).to include("AMCA")
      expect(id.to_s).to include("210")
    end

    it "parses AMCA standard with code suffix" do
      id = described_class.parse("AMCA 500-D")
      expect(id.to_s).to include("AMCA")
      expect(id.to_s).to include("500")
    end

    it "parses ANSI/AMCA joint standard" do
      id = described_class.parse("ANSI/AMCA 210-16")
      expect(id.to_s).to include("AMCA")
    end

    it "parses AMCA publication with reaffirmation" do
      id = described_class.parse("AMCA Publication 311-16 (R2020)")
      expect(id.to_s).to include("AMCA")
    end
  end

  describe "#to_urn" do
    it "generates URN" do
      id = described_class.parse("AMCA 210-16")
      expect(id.to_urn).to start_with("urn:amca:")
    end

    it "includes code in URN" do
      id = described_class.parse("AMCA 210-16")
      expect(id.to_urn).to include("210")
    end
  end
end
