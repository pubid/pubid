# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Components::Relationship do
  describe "constants" do
    it "exposes VALID_TYPES for validation" do
      %i[REVISION_OF ADOPTION_OF SUPERSEDES].each do |const|
        expect(described_class::VALID_TYPES)
          .to include(described_class.const_get(const))
      end
    end

    it "freezes VALID_TYPES so flavors cannot mutate it" do
      expect(described_class::VALID_TYPES).to be_frozen
    end
  end

  describe "#initialize" do
    it "normalizes INCORPORATING to INCORPORATES" do
      rel = described_class.new(
        relationship_type: described_class::INCORPORATING,
        related_identifiers: [],
      )
      expect(rel.relationship_type).to eq(described_class::INCORPORATES)
    end

    it "raises ArgumentError on an unknown relationship type" do
      expect do
        described_class.new(relationship_type: "bogus_type")
      end.to raise_error(ArgumentError, /Invalid relationship type/)
    end
  end

  describe "#to_s" do
    let(:base_id) { Pubid::Iso::Identifier.parse("ISO 9001:2015") }

    it "renders 'Revision of <id>' for REVISION_OF" do
      rel = described_class.new(
        relationship_type: described_class::REVISION_OF,
        related_identifiers: [base_id],
      )
      expect(rel.to_s).to eq("Revision of ISO 9001:2015")
    end

    it "renders 'Supersedes <id>' for SUPERSEDES" do
      rel = described_class.new(
        relationship_type: described_class::SUPERSEDES,
        related_identifiers: [base_id],
      )
      expect(rel.to_s).to eq("Supersedes ISO 9001:2015")
    end

    it "joins two identifiers with 'and'" do
      other = Pubid::Iso::Identifier.parse("ISO 14001:2015")
      rel = described_class.new(
        relationship_type: described_class::INCLUDES,
        related_identifiers: [base_id, other],
      )
      expect(rel.to_s)
        .to eq("Includes ISO 9001:2015 and ISO 14001:2015")
    end

    it "uses Oxford comma for 3+ identifiers" do
      a = Pubid::Iso::Identifier.parse("ISO 9001:2015")
      b = Pubid::Iso::Identifier.parse("ISO 14001:2015")
      c = Pubid::Iso::Identifier.parse("ISO 27001:2013")
      rel = described_class.new(
        relationship_type: described_class::INCLUDES,
        related_identifiers: [a, b, c],
      )
      expect(rel.to_s)
        .to eq("Includes ISO 9001:2015, ISO 14001:2015, and ISO 27001:2013")
    end

    it "appends 'as amended by ...' clause" do
      amd = Pubid::Iso::Identifier.parse("ISO 9001:2015/Amd 1")
      rel = described_class.new(
        relationship_type: described_class::REVISION_OF,
        related_identifiers: [base_id],
        intermediate_amendments: [amd],
      )
      expect(rel.to_s)
        .to eq("Revision of ISO 9001:2015 as amended by ISO 9001:2015/Amd 1")
    end

    it "appends 'and its approved amendments' when flag is set" do
      rel = described_class.new(
        relationship_type: described_class::REVISION_OF,
        related_identifiers: [base_id],
        approved_amendments_flag: true,
      )
      expect(rel.to_s)
        .to eq("Revision of ISO 9001:2015 and its approved amendments")
    end

    it "returns empty string when related_identifiers is empty" do
      rel = described_class.new(
        relationship_type: described_class::REVISION_OF,
        related_identifiers: [],
      )
      expect(rel.to_s).to eq("")
    end
  end

  describe "#render" do
    it "delegates to to_s" do
      base_id = Pubid::Iso::Identifier.parse("ISO 9001:2015")
      rel = described_class.new(
        relationship_type: described_class::REVISION_OF,
        related_identifiers: [base_id],
      )
      expect(rel.render).to eq(rel.to_s)
    end
  end
end
