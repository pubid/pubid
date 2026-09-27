# frozen_string_literal: true

require "pubid/ieee"

RSpec.describe Pubid::Ieee::Identifiers::IecIeeeCopublished do
  describe "C3 copublished print tails" do
    it "routes a (Revision of IEEE Std ...) narrative into relationships" do
      id = described_class.parse("IEC/IEEE 62271-37-082:2012(E) (Revision of IEEE Std C37.082-1982)")

      expect(id.to_s).to eq("IEC/IEEE 62271-37-082:2012(E)")
      expect(id.to_urn)
        .to eq("urn:ieee:iec-ieee:62271-37-082:2012(E):rel.Revision of IEEE Std C37.082-1982")
      expect(id.relationships.map(&:relationship_type)).to eq(["revision_of"])
      expect(id.relationships.first.related_identifiers.first.to_s)
        .to eq("IEEE Std C37.082-1982")
    end

    it "keeps the narrative off the hash while the relationship type survives round-trip" do
      id = described_class.parse("IEC/IEEE 62271-37-082:2012(E) (Revision of IEEE Std C37.082-1982)")

      expect(id.to_hash).not_to have_key("date_info")
      expect(described_class.from_hash(id.to_hash).to_hash).to eq(id.to_hash)
    end

    it "treats the bare (unparenthesised) narrative as the same relationship" do
      id = described_class.parse("IEC/IEEE 62271-37-082:2012(E) Revision of IEEE Std C37.082-1982")

      expect(id.to_s).to eq("IEC/IEEE 62271-37-082:2012(E)")
      expect(id.to_urn)
        .to eq("urn:ieee:iec-ieee:62271-37-082:2012(E):rel.Revision of IEEE Std C37.082-1982")
      expect(id.relationships.map(&:relationship_type)).to eq(["revision_of"])
    end

    it "drops an (MM/DD) print date as non-identity" do
      id = described_class.parse("IEC/IEEE 60079-30-2/D5 IEC:2013 (10/07)")

      expect(id.to_s).to eq("IEC/IEEE 60079-30-2/D5 IEC:2013")
      expect(id.to_urn).to eq("urn:ieee:iec-ieee:60079-30-2:draft./D5")
      expect(id.to_hash).not_to have_key("date_info")
    end

    it "leaves the narrative-bearing Redline alias on the same canonical" do
      id = described_class.parse(
        "IEC/IEEE 62271-37-082:2012(E) (Revision of IEEE Std C37.082-1982) - Redline",
      )

      expect(id.to_s).to eq("IEC/IEEE 62271-37-082:2012(E)")
    end

    it "renders the plain form unchanged" do
      id = described_class.parse("IEC/IEEE 62271-37-082:2012(E)")

      expect(id.to_s).to eq("IEC/IEEE 62271-37-082:2012(E)")
      expect(id.to_urn).to eq("urn:ieee:iec-ieee:62271-37-082:2012(E)")
      expect(id.relationships).to be_nil
    end
  end
end
