# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::AllPartsIdentifier do
  def iso(str)
    Pubid::Iso.parse(str)
  end

  def all_of(*ids)
    described_class.new(identifiers: ids)
  end

  describe "construction" do
    it "sorts the members in natural order" do
      wrapper = all_of(iso("ISO 9000-10"), iso("ISO 9000-2"), iso("ISO 9000-1"))
      expect(wrapper.identifiers.map(&:to_s))
        .to eq(["ISO 9000-1", "ISO 9000-2", "ISO 9000-10"])
    end

    it "removes a duplicate member" do
      wrapper = all_of(iso("ISO 9000-1"), iso("ISO 9000-1"))
      expect(wrapper.identifiers.size).to eq(1)
    end

    it "removes the whole-document member when parts exist" do
      wrapper = all_of(iso("ISO 9000"), iso("ISO 9000-1"))
      expect(wrapper.identifiers.map(&:to_s)).to eq(["ISO 9000-1"])
    end

    it "keeps the whole-document member when it is the only member" do
      wrapper = all_of(iso("ISO 9000"))
      expect(wrapper.identifiers.map(&:to_s)).to eq(["ISO 9000"])
    end
  end

  describe "#==" do
    it "is true for the same parts in any order" do
      expect(all_of(iso("ISO 9000-1"), iso("ISO 9000-2")))
        .to eq(all_of(iso("ISO 9000-2"), iso("ISO 9000-1")))
    end

    it "is false for different parts" do
      expect(all_of(iso("ISO 9000-1"))).not_to eq(all_of(iso("ISO 9000-2")))
    end

    it "is false against a plain identifier" do
      id = iso("ISO 9000-1")
      expect(all_of(id) == id).to be false
    end
  end

  describe "#to_s" do
    {
      "ISO 9000-1:2015" => "ISO 9000 (all parts)",
      "ISO/IEC 27001-1" => "ISO/IEC 27001 (all parts)",
      "ECMA-418-1 ed1" => "ECMA-418 (all parts)",
      "ETSI TS 129 198-4 V1.1.1 (2002-01)" => "ETSI TS 129 198 (all parts)",
    }.each do |ref, rendered|
      it "renders #{ref} as #{rendered}" do
        expect(Pubid.parse(ref).to_all_parts.to_s).to eq(rendered)
      end
    end

    it "prints no date when the members have different years" do
      wrapper = all_of(iso("ISO 9000-1:2015"), iso("ISO 9000-2:2018"))
      expect(wrapper.to_s).to eq("ISO 9000 (all parts)")
    end

    it "accepts annotated:" do
      expect { all_of(iso("ISO 9000-1")).to_s(annotated: true) }
        .not_to raise_error
    end
  end

  describe "serialization" do
    let(:wrapper) { all_of(iso("ISO 9000-1:2015"), iso("ISO 9000-2")) }

    it "writes the members under identifiers, and nothing else" do
      hash = wrapper.to_hash
      expect(hash.keys).to contain_exactly("_type", "identifiers")
      expect(hash["_type"]).to eq("pubid:all-parts")
      expect(hash["identifiers"].map { |h| h["_type"] })
        .to all(eq("pubid:iso:international-standard"))
    end

    it "round-trips through Pubid::Identifier.from_hash" do
      expect(Pubid::Identifier.from_hash(wrapper.to_hash)).to eq(wrapper)
    end

    it "round-trips through Pubid.from_hash" do
      expect(Pubid.from_hash(wrapper.to_hash)).to eq(wrapper)
    end

    # A row written before "all parts" became a class.
    it "reads the old all_parts flag" do
      legacy = { "_type" => "pubid:iso:international-standard",
                 "number" => "9000", "all_parts" => true }
      id = Pubid.from_hash(legacy)
      expect(id).to be_a(Pubid::AllParts)
      expect(id.to_s).to eq("ISO 9000 (all parts)")
    end

    # lutaml assigns the members after #initialize, so from_hash must
    # normalize them itself.
    it "normalizes the members of a hash that is not in order" do
      hash = wrapper.to_hash
      members = hash["identifiers"]
      whole = iso("ISO 9000").to_hash
      unordered = hash.merge("identifiers" => [members[1], whole, members[0],
                                               members[1]])
      expect(Pubid.from_hash(unordered)).to eq(wrapper)
    end
  end

  describe "#===" do
    {
      Pubid::Iso => ["ISO 9000-1:2015", "ISO 9000-3:2018"],
      Pubid::Ecma => ["ECMA-418-1 ed1", "ECMA-418-2 ed2"],
      Pubid::Etsi => ["ETSI TS 129 198-4 V1.1.1 (2002-01)",
                      "ETSI TS 129 198-5 V1.2.1 (2003-01)"],
      Pubid::Tgpp => ["3GPP TS 29.198-04-1", "3GPP TS 29.198-05"],
      Pubid::Jis => ["JIS B 0001-1:2019", "JIS B 0001-2:2020"],
    }.each do |flavor, (ref, other)|
      it "matches another part of #{ref} in another edition: #{other}" do
        all = flavor.parse(ref).to_all_parts
        expect(all === flavor.parse(other)).to be true
      end
    end

    it "matches the whole document" do
      expect(iso("ISO 9000-1").to_all_parts === iso("ISO 9000:2015")).to be true
    end

    it "does not match a different number" do
      expect(iso("ISO 9000-1").to_all_parts === iso("ISO 9001-1")).to be false
    end

    it "does not match a different stage" do
      dis = iso("ISO/DIS 9000-2")
      expect(iso("ISO 9000-1").to_all_parts === dis).to be false
    end

    it "matches another all-parts identifier of the same document" do
      other = iso("ISO 9000-4").to_all_parts
      expect(iso("ISO 9000-1:2015").to_all_parts === other)
        .to be true
    end

    it "is false for a non-identifier" do
      expect(iso("ISO 9000-1").to_all_parts === "ISO 9000").to be false
    end
  end

  describe "#+" do
    let(:wrapper) { iso("ISO 9000-2").to_all_parts }

    it "returns a new identifier with the part in sorted order" do
      sum = wrapper + iso("ISO 9000-1")
      expect(sum).to be_a(Pubid::AllParts)
      expect(sum).not_to equal(wrapper)
      expect(sum.identifiers.map(&:to_s)).to eq(["ISO 9000-1", "ISO 9000-2"])
    end

    it "does not change the receiver" do
      wrapper + iso("ISO 9000-1")
      expect(wrapper.identifiers.map(&:to_s)).to eq(["ISO 9000-2"])
    end

    it "replaces the whole-document member" do
      sum = iso("ISO 9000").to_all_parts + iso("ISO 9000-1")
      expect(sum.identifiers.map(&:to_s)).to eq(["ISO 9000-1"])
    end

    it "accepts a part of another edition" do
      expect((wrapper + iso("ISO 9000-3:2018")).identifiers.size).to eq(2)
    end

    it "accepts another all-parts identifier" do
      sum = wrapper + iso("ISO 9000-1").to_all_parts
      expect(sum.identifiers.map(&:to_s)).to eq(["ISO 9000-1", "ISO 9000-2"])
    end

    {
      "a different document" => "ISO 9001-1",
      "a member with no part" => "ISO 9000",
      "a duplicate" => "ISO 9000-2",
    }.each do |label, ref|
      it "raises for #{label}" do
        expect { wrapper + iso(ref) }.to raise_error(ArgumentError)
      end
    end

    it "raises for a non-identifier" do
      expect { wrapper + 42 }.to raise_error(ArgumentError)
    end
  end

  describe "document accessors" do
    let(:wrapper) { iso("ISO 9000-1:2015").to_all_parts }

    it "gives the document number" do
      expect(wrapper.number).to eq("9000")
      expect(wrapper.root.number).to eq("9000")
    end

    it "keeps the document itself out of the public interface" do
      expect(wrapper.respond_to?(:identity)).to be false
    end

    it "keeps its class through exclude" do
      expect(wrapper.exclude(:date)).to be_a(Pubid::AllParts)
      expect(wrapper.exclude(:date).identifiers.first.year).to be_nil
    end

    it "returns itself from to_all_parts" do
      expect(wrapper.to_all_parts).to equal(wrapper)
    end

    # A flavor with no all-parts class of its own has no URN yet.
    it "has no URN in a flavor without its own all-parts class" do
      ecma = Pubid::Ecma.parse("ECMA-418-1 ed1").to_all_parts
      expect { ecma.to_urn }.to raise_error(NotImplementedError)
    end

    it "renders the human form through render" do
      expect(wrapper.render).to eq("ISO 9000 (all parts)")
    end

    it "has no MR string or slug yet" do
      expect { wrapper.to_mr_string }.to raise_error(NotImplementedError)
      expect { wrapper.to_slug }.to raise_error(NotImplementedError)
    end
  end
end
