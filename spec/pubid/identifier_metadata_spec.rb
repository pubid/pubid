# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/pubid/identifier_registry"

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
      # The metadata should be accessible if the class has it defined
      expect(id.class).to respond_to(:metadata)
    end
  end
end

RSpec.describe Pubid::IdentifierRegistry do
  before(:each) do
    # Clear registry before each test
    described_class.clear!
  end

  describe ".register" do
    it "registers an identifier class" do
      described_class.register(
        Pubid::Iso::Identifiers::InternationalStandard,
        flavor: :iso,
        type_key: :is,
        title: "International Standard",
      )

      expect(described_class.all_identifiers.size).to eq(1)
    end
  end

  describe ".find_by_type" do
    before do
      described_class.register(
        Pubid::Iso::Identifiers::InternationalStandard,
        flavor: :iso,
        type_key: :is,
        title: "International Standard",
        abbr: ["", "IS"],
      )
    end

    it "finds identifier by flavor and type key" do
      found = described_class.find_by_type(:iso, :is)
      expect(found).to eq(Pubid::Iso::Identifiers::InternationalStandard)
    end

    it "returns nil for unknown type" do
      found = described_class.find_by_type(:iso, :unknown)
      expect(found).to be_nil
    end
  end

  describe ".find_by_abbr" do
    before do
      described_class.register(
        Pubid::Iso::Identifiers::InternationalStandard,
        flavor: :iso,
        type_key: :is,
        title: "International Standard",
        abbr: ["", "IS", "is"],
      )
    end

    it "finds identifier by abbreviation" do
      found = described_class.find_by_abbr(:iso, "IS")
      expect(found).to include(Pubid::Iso::Identifiers::InternationalStandard)
    end

    it "is case-insensitive" do
      found = described_class.find_by_abbr(:iso, "is")
      expect(found).to include(Pubid::Iso::Identifiers::InternationalStandard)
    end
  end

  describe ".search" do
    before do
      described_class.register(
        Pubid::Iso::Identifiers::InternationalStandard,
        flavor: :iso,
        type_key: :is,
        title: "International Standard",
        abbr: ["IS"],
        base_class: "SingleIdentifier",
      )
    end

    it "searches by flavor" do
      results = described_class.search(flavor: :iso)
      expect(results.size).to eq(1)
      expect(results.first[:class]).to eq(Pubid::Iso::Identifiers::InternationalStandard)
    end

    it "searches by title" do
      results = described_class.search(title: "International")
      expect(results.size).to eq(1)
    end

    it "searches by base_class status" do
      results = described_class.search(base_class: true)
      expect(results.size).to eq(1)
    end
  end

  describe ".metadata_for" do
    before do
      described_class.register(
        Pubid::Iso::Identifiers::InternationalStandard,
        flavor: :iso,
        type_key: :is,
        title: "International Standard",
        abbr: ["IS"],
      )
    end

    it "returns metadata for a registered class" do
      metadata = described_class.metadata_for(Pubid::Iso::Identifiers::InternationalStandard)
      expect(metadata).to be_a(Pubid::IdentifierMetadata::Metadata)
      expect(metadata.type_key).to eq(:is)
      expect(metadata.title).to eq("International Standard")
    end
  end
end
