# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::IdentifierMetadata do
  describe "Metadata" do
    let(:metadata) do
      described_class::Metadata.new(
        flavor: :iso,
        identifier_class: "InternationalStandard",
        type_key: :is,
        title: "International Standard",
        short: "IS",
        abbr: ["", "IS"],
        base_class: "SingleIdentifier",
        stage_codes: %i[dp wd cd],
        machine_codes: { iso_stage: ["40.60", "60.60"] },
      )
    end

    it "has a slug for file naming" do
      expect(metadata.slug).to eq("iso-is")
    end

    it "has a URN for machine identification" do
      expect(metadata.urn).to eq("urn:pubid:iso:type:is")
    end

    it "has a qualified class name" do
      expect(metadata.qualified_class_name).to eq("Iso::InternationalStandard")
    end

    it "matches codes correctly" do
      expect(metadata.matches_code?("IS")).to be true
      expect(metadata.matches_code?("is")).to be true
      expect(metadata.matches_code?("")).to be true
      expect(metadata.matches_code?("AMD")).to be false
    end

    it "converts to hash" do
      hash = metadata.to_h
      expect(hash[:flavor]).to eq(:iso)
      expect(hash[:type_key]).to eq(:is)
      expect(hash[:title]).to eq("International Standard")
      expect(hash[:abbr]).to eq(["", "IS"])
      expect(hash[:slug]).to eq("iso-is")
    end
  end

  describe "ClassMethods" do
    it "is included in identifier classes" do
      expect(Pubid::Iso::Identifiers::InternationalStandard)
        .to respond_to(:define_metadata)
    end
  end

  describe "InstanceMethods" do
    it "provides metadata access on instances" do
      id = Pubid::Iso.parse("ISO 9001:2015")
      expect(id.class).to respond_to(:metadata)
    end
  end
end
