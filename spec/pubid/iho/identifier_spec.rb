# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Iho::Identifier do
  shared_examples "round-trips an IHO identifier" do
    it "parses and renders the canonical form" do
      expect(Pubid::Iho.parse(input).to_s).to eq(canonical)
    end
  end

  describe ".parse" do
    {
      "IHO S-44 5.0.0" => "IHO S-44 5.0.0",
      "IHO S-100 5.2.0" => "IHO S-100 5.2.0",
      "IHO M-3 2.0.0" => "IHO M-3 2.0.0",
      "IHO B-4 2.19.0" => "IHO B-4 2.19.0",
      "IHO C-13 1.0.0" => "IHO C-13 1.0.0",
      # letter-suffixed numbers (the letter is part of the document number)
      "IHO S-5A 1.0.2" => "IHO S-5A 1.0.2",
      "IHO S-8B 1.0.0" => "IHO S-8B 1.0.0",
      # colon-separated sub-publication
      "IHO S-158:100 1.0.0" => "IHO S-158:100 1.0.0",
      # slash sub-part
      "IHO P-1/21 1.0.0" => "IHO P-1/21 1.0.0",
      # hyphen sub-part
      "IHO P-6-3 1.0.0" => "IHO P-6-3 1.0.0",
      # appendix with letter
      "IHO S-65 Ap. A 1.0.0" => "IHO S-65 Ap. A 1.0.0",
      # appendix with number
      "IHO S-53 Ap. 1 1.0.0" => "IHO S-53 Ap. 1 1.0.0",
      # part variants
      "IHO S-100 Part 1 1.0.0" => "IHO S-100 Part 1 1.0.0",
      "IHO S-100 Part A 1.0.0" => "IHO S-100 Part A 1.0.0",
      "IHO S-100 Part A" => "IHO S-100 Part A",
      "IHO S-4 Part 2 4.9.0" => "IHO S-4 Part 2 4.9.0",
      # part with letter suffix (relaton-iho issue 23)
      "IHO S-100 Part 4a 1.0.0" => "IHO S-100 Part 4a 1.0.0",
      "IHO S-100 Part 4b 1.0.0" => "IHO S-100 Part 4b 1.0.0",
      "IHO S-100 Part 4c 1.0.0" => "IHO S-100 Part 4c 1.0.0",
      "IHO S-100 Part 17a 1.0.0" => "IHO S-100 Part 17a 1.0.0",
      "IHO S-100 Part 4a" => "IHO S-100 Part 4a",
      # annex (S-100 Annex A "Terms and Definitions", S-98 Annex A/B/C)
      "IHO S-100 Annex A 5.2.0" => "IHO S-100 Annex A 5.2.0",
      "IHO S-100 Annex A" => "IHO S-100 Annex A",
      "IHO S-98 Annex C 1.0.0" => "IHO S-98 Annex C 1.0.0",
      # appendix with letter-digit value form (S-122/S-123 Appendix D-2)
      "IHO S-122 Ap. D-2 1.0.0" => "IHO S-122 Ap. D-2 1.0.0",
      # Appendix wording is accepted as input alias, canonicalises to Ap.
      "IHO S-122 Appendix A 1.0.0" => "IHO S-122 Ap. A 1.0.0",
      "IHO S-122 Appendix D-2 1.0.0" => "IHO S-122 Ap. D-2 1.0.0",
      # supplement (S-66 Suppl 1..4)
      "IHO S-66 Suppl 1 1.0.0" => "IHO S-66 Suppl 1 1.0.0",
      "IHO S-66 Suppl 4 1.0.0" => "IHO S-66 Suppl 4 1.0.0",
      # IHO prefix is optional on input, always emitted on output
      "S-100 Part 4a 1.0.0" => "IHO S-100 Part 4a 1.0.0",
      "S-100 Annex A 5.2.0" => "IHO S-100 Annex A 5.2.0",
      "S-44 5.0.0" => "IHO S-44 5.0.0",
      "S-66 Suppl 1 1.0.0" => "IHO S-66 Suppl 1 1.0.0",
      # year-identified series (relaton#407): B-7/P-5/P-6 carry a year
      # instead of the placeholder a.b.c edition
      "IHO P-5 2024" => "IHO P-5 2024",
      "IHO B-7 2023" => "IHO B-7 2023",
      "P-5 2024" => "IHO P-5 2024",
      # volume/issue-identified series (P-1, the IHR)
      "IHO P-1 Vol. 30" => "IHO P-1 Vol. 30",
      "IHO P-1 Vol. 30 (2)" => "IHO P-1 Vol. 30 (2)",
      # the "Issue N" spelling is an input alias; the parenthesized
      # form is the canonical print
      "IHO P-1 Vol. 30 Issue 2" => "IHO P-1 Vol. 30 (2)",
    }.each do |input, canonical|
      context "with #{input.inspect}" do
        let(:input)     { input }
        let(:canonical) { canonical }

        it_behaves_like "round-trips an IHO identifier"
      end
    end

    it "raises on garbage input" do
      expect do
        Pubid::Iho.parse("not an IHO identifier")
      end.to raise_error(Pubid::Errors::ParseError)
    end

    # A two-segment version is deliberately not a tail discriminator:
    # no IHO series carries one in the corpus, and neither new rule
    # swallows it (a year needs all four digits of 19xx/20xx; a dotted
    # version needs all three segments).
    it "raises on a two-segment version" do
      expect do
        Pubid::Iho.parse("IHO B-12 3.0")
      end.to raise_error(Pubid::Errors::ParseError)
    end
  end

  describe "type-specific dispatch" do
    {
      "S" => Pubid::Iho::Identifiers::Standard,
      "P" => Pubid::Iho::Identifiers::Publication,
      "M" => Pubid::Iho::Identifiers::Miscellaneous,
      "B" => Pubid::Iho::Identifiers::Bibliographic,
      "C" => Pubid::Iho::Identifiers::CircularLetter,
    }.each do |letter, klass|
      it "maps the #{letter}- prefix to #{klass.name.split('::').last}" do
        expect(Pubid::Iho.parse("IHO #{letter}-1 1.0.0")).to be_a(klass)
      end
    end
  end

  describe "key_value serialization" do
    # Used by the relaton index: each id is stored as #to_hash and rebuilt via
    # .from_hash, so the round-trip must be lossless and the hash must be lean.
    [
      "IHO S-100 5.2.0",
      "IHO S-100 Part 4b 5.2.0",
      "IHO S-122 Ap. D-2 1.0.0",
      "IHO S-100 Annex A 5.2.0",
      "IHO S-66 Suppl 1 2.0.0",
      "IHO B-1 1.0.0",
      "IHO P-1/21 1.0.0",
      "IHO M-3 2.0.0",
      "IHO C-13 1.0.0",
      "IHO B-12 3.0.0",
      "IHO P-5 2024",
      "IHO P-1 Vol. 30",
      "IHO P-1 Vol. 30 (2)",
    ].each do |canonical|
      context "with #{canonical.inspect}" do
        let(:pubid) { Pubid::Iho.parse(canonical) }

        it "round-trips losslessly through to_hash/from_hash" do
          expect(Pubid::Iho::Identifier.from_hash(pubid.to_hash).to_s)
            .to eq(canonical)
        end

        # == is what #matches? compares through (it excludes and
        # rebuilds), so the deserialized id must equal the parsed one,
        # not merely render alike.
        it "rebuilds an == identifier from its own hash" do
          expect(Pubid::Iho::Identifier.from_hash(pubid.to_hash))
            .to eq(pubid)
        end

        it "stores the document number under :number" do
          expect(pubid.to_hash["number"]).to eq(pubid.number)
        end

        it "omits the derived :code and default :publisher keys" do
          expect(pubid.to_hash).not_to include("code", "publisher")
        end
      end
    end

    it "exposes the document number via #number for index narrowing" do
      expect(Pubid::Iho.parse("IHO S-100 Part 5").number).to eq("100")
    end

    it "covers every identifier type in IHO_TYPE_MAP" do
      expected = Pubid::Iho.identifier_types.map(&:polymorphic_name).sort
      expect(Pubid::Iho::Identifier::IHO_TYPE_MAP.keys.sort)
        .to eq(expected)
    end
  end

  describe "series components (relaton#407)" do
    # The grammar's tail picks exactly one discriminator; the issue
    # only ever rides beside a volume.
    it "parses a year into a plain string year" do
      id = Pubid::Iho.parse("IHO P-5 2024")
      expect(id.year).to eq("2024")
      expect(id.version).to be_nil
      expect(id.volume).to be_nil
    end

    it "parses a volume and issue into plain string scalars" do
      id = Pubid::Iho.parse("IHO P-1 Vol. 30 (2)")
      expect(id.volume).to eq("30")
      expect(id.issue).to eq("2")
      expect(id.version).to be_nil
      expect(id.year).to be_nil
    end

    # "P-1 Vol. 30" must match "P-1 Vol. 30 (2)" under exclude(:volume):
    # the issue is the volume's scalar sibling, so the exclusion nils
    # the whole cluster (the base's :year -> :date alias shape).
    it "nils the volume/issue cluster on exclude(:volume)" do
      dated = Pubid::Iho.parse("IHO P-1 Vol. 30 (2)")
      bare = Pubid::Iho.parse("IHO P-1 Vol. 30")
      excluded = dated.exclude(:volume)
      expect(excluded.volume).to be_nil
      expect(excluded.issue).to be_nil
      expect(excluded).to eq(bare.exclude(:volume))
    end

    # A lone scalar year needs no override: the base nils a declared
    # :year directly (the additive :year -> :date alias).
    it "nils the year on exclude(:year)" do
      expect(Pubid::Iho.parse("IHO P-5 2024").exclude(:year).year).to be_nil
    end
  end
end
