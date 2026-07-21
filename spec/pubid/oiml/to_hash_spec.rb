# frozen_string_literal: true

require "spec_helper"

module OimlToHashSpec
  # Representative ids spanning every existing OIML form.
  ROUND_TRIP_IDS = [
    "OIML R 106",
    "OIML B 18:2018",
    "OIML R 117-1:2019",
    "OIML V 2-200:2012",
    "OIML R 106(E)",
    "OIML R 60 Edition 2013",
    "OIML R 60 Annexes:2021 (E)",
    "OIML R 60 Annex A Edition 2013 (E)",
    "Amendment (2009) to OIML R 138 Edition 2007 (E)",
  ].freeze
end

# Round-trip serialization for OIML identifiers: every id must survive
# `to_hash` and reconstruct via `Pubid::Oiml::Identifier.from_hash`. This is
# the contract relaton-index relies on when building a structured index-v2.yaml.
RSpec.describe "Pubid::Oiml to_hash/from_hash round-trip" do
  describe "#to_hash" do
    it "serializes without raising IncorrectModelError" do
      OimlToHashSpec::ROUND_TRIP_IDS.each do |str|
        id = Pubid::Oiml.parse(str)
        expect do
          id.to_hash
        end.not_to raise_error, "to_hash raised for #{str.inspect}"
      end
    end

    it "emits the polymorphic _type discriminator" do
      id = Pubid::Oiml.parse("OIML B 18:2018")
      expect(id.to_hash["_type"]).to eq("pubid:oiml:basic-publication")
    end

    it "does not emit a String type attribute" do
      id = Pubid::Oiml.parse("OIML B 18:2018")
      expect(id.to_hash).not_to have_key("type")
    end
  end

  describe ".from_hash" do
    it "round-trips every representative form back to the same string" do
      OimlToHashSpec::ROUND_TRIP_IDS.each do |str|
        id = Pubid::Oiml.parse(str)
        restored = Pubid::Oiml::Identifier.from_hash(id.to_hash)
        expect(restored.to_s).to eq(id.to_s), 
                                 "round-trip mismatch for #{str.inspect}"
      end
    end

    it "reconstructs the concrete subclass from _type" do
      id = Pubid::Oiml.parse("OIML B 18:2018")
      restored = Pubid::Oiml::Identifier.from_hash(id.to_hash)
      expect(restored).to be_a(Pubid::Oiml::Identifiers::BasicPublication)
    end

    it "reconstructs nested supplement base identifiers" do
      id = Pubid::Oiml.parse("Amendment (2009) to OIML R 138 Edition 2007 (E)")
      restored = Pubid::Oiml::Identifier.from_hash(id.to_hash)
      expect(restored).to be_a(Pubid::Oiml::Identifiers::Amendment)
      expect(restored.base).to be_a(Pubid::Oiml::Identifiers::Recommendation)
    end
  end

  describe "polymorphic_name registry" do
    it "every concrete identifier class maps in OIML_TYPE_MAP" do
      Pubid::Oiml::Identifiers.constants.each do |const|
        klass = Pubid::Oiml::Identifiers.const_get(const)
        next unless klass.is_a?(Class) && klass < Pubid::Identifier

        poly = klass.polymorphic_name
        expect(Pubid::Oiml::Identifier::OIML_TYPE_MAP).to have_key(poly),
                                                          "#{klass} (#{poly}) missing from OIML_TYPE_MAP"
        expect(Object.const_get(Pubid::Oiml::Identifier::OIML_TYPE_MAP[poly])).to eq(klass)
      end
    end
  end
end
