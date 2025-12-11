# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Ieee::Components::Relationship do
  describe "constants" do
    it "defines all relationship types" do
      expect(described_class::REVISION_OF).to eq("revision_of")
      expect(described_class::AMENDMENT_TO).to eq("amendment_to")
      expect(described_class::CORRIGENDUM_TO).to eq("corrigendum_to")
      expect(described_class::INCORPORATES).to eq("incorporates")
      expect(described_class::INCORPORATING).to eq("incorporating")
      expect(described_class::ADOPTION_OF).to eq("adoption_of")
      expect(described_class::SUPPLEMENT_TO).to eq("supplement_to")
      expect(described_class::DRAFT_AMENDMENT_TO).to eq("draft_amendment_to")
      expect(described_class::DRAFT_REVISION_OF).to eq("draft_revision_of")
    end

    it "includes all types in VALID_TYPES" do
      expect(described_class::VALID_TYPES).to include(
        described_class::REVISION_OF,
        described_class::AMENDMENT_TO,
        described_class::CORRIGENDUM_TO,
        described_class::INCORPORATES,
        described_class::INCORPORATING,
        described_class::ADOPTION_OF,
        described_class::SUPPLEMENT_TO,
        described_class::DRAFT_AMENDMENT_TO,
        described_class::DRAFT_REVISION_OF
      )
    end
  end

  describe "#initialize" do
    it "accepts valid relationship type" do
      relationship = described_class.new(
        relationship_type: described_class::REVISION_OF
      )
      expect(relationship.relationship_type).to eq("revision_of")
    end

    it "raises error for invalid relationship type" do
      expect {
        described_class.new(relationship_type: "invalid_type")
      }.to raise_error(ArgumentError, /Invalid relationship type/)
    end

    it "accepts nil relationship type without validation" do
      relationship = described_class.new
      expect(relationship.relationship_type).to be_nil
    end
  end

  describe "#to_s with single identifier" do
    let(:related_id) do
      PubidNew::Ieee::Identifiers::Base.new(
        publisher: "IEEE",
        type: "Std",
        code: "802.11",
        year: "2012"
      )
    end

    it "renders revision_of" do
      relationship = described_class.new(
        relationship_type: described_class::REVISION_OF,
        related_identifiers: [related_id]
      )
      expect(relationship.to_s).to eq("Revision of IEEE Std 802.11-2012")
    end

    it "renders amendment_to" do
      relationship = described_class.new(
        relationship_type: described_class::AMENDMENT_TO,
        related_identifiers: [related_id]
      )
      expect(relationship.to_s).to eq("Amendment to IEEE Std 802.11-2012")
    end

    it "renders corrigendum_to" do
      relationship = described_class.new(
        relationship_type: described_class::CORRIGENDUM_TO,
        related_identifiers: [related_id]
      )
      expect(relationship.to_s).to eq("Corrigendum to IEEE Std 802.11-2012")
    end

    it "renders incorporates" do
      relationship = described_class.new(
        relationship_type: described_class::INCORPORATES,
        related_identifiers: [related_id]
      )
      expect(relationship.to_s).to eq("incorporates IEEE Std 802.11-2012")
    end

    it "renders adoption_of" do
      relationship = described_class.new(
        relationship_type: described_class::ADOPTION_OF,
        related_identifiers: [related_id]
      )
      expect(relationship.to_s).to eq("Adoption of IEEE Std 802.11-2012")
    end
  end

  describe "#to_s with two identifiers" do
    let(:id1) do
      PubidNew::Ieee::Identifiers::Base.new(
        publisher: "IEEE",
        type: "Std",
        code: "1232",
        year: "1995"
      )
    end

    let(:id2) do
      PubidNew::Ieee::Identifiers::Base.new(
        publisher: "IEEE",
        type: "Std",
        code: "1232.1",
        year: "1997"
      )
    end

    it "uses 'and' for two identifiers" do
      relationship = described_class.new(
        relationship_type: described_class::REVISION_OF,
        related_identifiers: [id1, id2]
      )
      expect(relationship.to_s).to eq("Revision of IEEE Std 1232-1995 and IEEE Std 1232.1-1997")
    end
  end

  describe "#to_s with three or more identifiers" do
    let(:id1) do
      PubidNew::Ieee::Identifiers::Base.new(
        publisher: "IEEE",
        type: "Std",
        code: "1232",
        year: "1995"
      )
    end

    let(:id2) do
      PubidNew::Ieee::Identifiers::Base.new(
        publisher: "IEEE",
        type: "Std",
        code: "1232.1",
        year: "1997"
      )
    end

    let(:id3) do
      PubidNew::Ieee::Identifiers::Base.new(
        publisher: "IEEE",
        type: "Std",
        code: "1232.2",
        year: "1998"
      )
    end

    it "uses Oxford comma for three identifiers" do
      relationship = described_class.new(
        relationship_type: described_class::REVISION_OF,
        related_identifiers: [id1, id2, id3]
      )
      expect(relationship.to_s).to eq("Revision of IEEE Std 1232-1995, IEEE Std 1232.1-1997, and IEEE Std 1232.2-1998")
    end
  end

  describe "#to_s with intermediate amendments" do
    let(:base_id) do
      PubidNew::Ieee::Identifiers::Base.new(
        publisher: "IEEE",
        type: "Std",
        code: "802.1Q",
        year: "2014"
      )
    end

    let(:amendment1) do
      PubidNew::Ieee::Identifiers::Base.new(
        publisher: "IEEE",
        type: "Std",
        code: "802.1Qca",
        year: "2015"
      )
    end

    let(:amendment2) do
      PubidNew::Ieee::Identifiers::Base.new(
        publisher: "IEEE",
        type: "Std",
        code: "802.1Qcd",
        year: "2015"
      )
    end

    it "includes 'as amended by' clause with single amendment" do
      relationship = described_class.new(
        relationship_type: described_class::AMENDMENT_TO,
        related_identifiers: [base_id],
        intermediate_amendments: [amendment1]
      )
      expect(relationship.to_s).to eq("Amendment to IEEE Std 802.1Q-2014 as amended by IEEE Std 802.1Qca-2015")
    end

    it "includes 'as amended by' clause with multiple amendments" do
      relationship = described_class.new(
        relationship_type: described_class::AMENDMENT_TO,
        related_identifiers: [base_id],
        intermediate_amendments: [amendment1, amendment2]
      )
      expect(relationship.to_s).to eq("Amendment to IEEE Std 802.1Q-2014 as amended by IEEE Std 802.1Qca-2015 and IEEE Std 802.1Qcd-2015")
    end
  end

  describe "edge cases" do
    it "returns empty string when no related identifiers" do
      relationship = described_class.new(
        relationship_type: described_class::REVISION_OF
      )
      expect(relationship.to_s).to eq("")
    end

    it "returns empty string when related_identifiers is empty array" do
      relationship = described_class.new(
        relationship_type: described_class::REVISION_OF,
        related_identifiers: []
      )
      expect(relationship.to_s).to eq("")
    end
  end
end