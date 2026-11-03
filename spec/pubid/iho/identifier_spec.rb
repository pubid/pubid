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
      # --- the two main syntaxes (edition-keyed products) ---
      "IHO S-100" => "IHO S-100", # undated (edition-non-specific)
      "IHO S-44 5.0.0" => "IHO S-44 5.0.0", # dated (edition-specific)
      "IHO S-100 5.2.0" => "IHO S-100 5.2.0",
      "IHO M-3 2.0.0" => "IHO M-3 2.0.0",
      "IHO B-4 2.19.0" => "IHO B-4 2.19.0",
      "IHO C-13 1.0.0" => "IHO C-13 1.0.0",
      # a dotted edition is the ONLY edition face; the official edition
      # carries no year
      "IHO S-100 v5.1" => "IHO S-100 5.1.0", # the v-shorthand alias
      "IHO S-100 v1" => "IHO S-100 1.0.0",

      # --- parts (lettered and numbered; compound "4a") ---
      "IHO S-98 1.0.0 Part A" => "IHO S-98 1.0.0 Part A",
      "IHO S-100 5.0.0 Part 2" => "IHO S-100 5.0.0 Part 2",
      "IHO S-100 Part 1 1.0.0" => "IHO S-100 1.0.0 Part 1", # legacy order
      "IHO S-100 Part A 1.0.0" => "IHO S-100 1.0.0 Part A",
      "IHO S-100 Part A" => "IHO S-100 Part A",
      "IHO S-4 Part 2 4.9.0" => "IHO S-4 4.9.0 Part 2",
      "IHO S-100 Part 4a 1.0.0" => "IHO S-100 1.0.0 Part 4a", # relaton-iho#23
      "IHO S-100 Part 4b 1.0.0" => "IHO S-100 1.0.0 Part 4b",
      "IHO S-100 Part 17a 1.0.0" => "IHO S-100 1.0.0 Part 17a",
      "IHO S-100 Part 4a" => "IHO S-100 Part 4a",
      # compact face (hyphenated onto the code); parses and renders
      "IHO S-5-B" => "IHO S-5 Part B",
      "IHO S-100-1 1.0.0" => "IHO S-100 1.0.0 Part 1",
      "IHO P-6-3 1.0.0" => "IHO P-6 1.0.0 Part 3",
      # legacy glued lettered bases (parse-only, never rendered)
      "IHO S-5A 1.0.2" => "IHO S-5 1.0.2 Part A",
      "IHO S-8B 1.0.0" => "IHO S-8 1.0.0 Part B",
      "IHO S-5A" => "IHO S-5 Part A",

      # --- annexes ---
      "IHO S-65 1.1.0 Annex A" => "IHO S-65 1.1.0 Annex A",
      "IHO S-100 Annex A 5.2.0" => "IHO S-100 5.2.0 Annex A",
      "IHO S-100 Annex A" => "IHO S-100 Annex A",
      "IHO S-98 Annex C 1.0.0" => "IHO S-98 1.0.0 Annex C",

      # --- appendices (canonical Appendix; App/Ap. are input aliases;
      #     the subnumber keeps its own component) ---
      "IHO S-122 1.0.0 Appendix D-2" => "IHO S-122 1.0.0 Appendix D-2",
      "IHO S-122 Ap. D-2 1.0.0" => "IHO S-122 1.0.0 Appendix D-2",
      "IHO S-52 4.0.0 Appendix 1" => "IHO S-52 4.0.0 Appendix 1",
      "IHO S-52 App 1 4.0.0" => "IHO S-52 4.0.0 Appendix 1",
      "IHO S-53 Ap. 1 1.0.0" => "IHO S-53 1.0.0 Appendix 1",
      "IHO S-65 Ap. B 1.2.0" => "IHO S-65 1.2.0 Appendix B",

      # --- supplements (canonical Sup; Suppl is the S-66 input alias) ---
      "IHO M-2 Sup 1" => "IHO M-2 Sup 1",
      "IHO M-2 Suppl 6" => "IHO M-2 Sup 6",
      "IHO S-66 2.0.0 Sup 4" => "IHO S-66 2.0.0 Sup 4",
      "IHO S-66 Suppl 4" => "IHO S-66 Sup 4",

      # --- serial locators: ONE component, the volume ---
      "IHO P-1 Vol. 30" => "IHO P-1 Vol. 30",
      "IHO P-1 Vol. 30 (2)" => "IHO P-1 Vol. 30 (2)",
      "IHO P-1 Vol. 30 Issue 2" => "IHO P-1 Vol. 30 (2)", # the Issue N alias
      "IHO P-1/21" => "IHO P-1 Vol. 21", # the slash chain
      "IHO P-1/21 1.0.0" => "IHO P-1 1.0.0 Vol. 21",
      "IHO P-5 Vol. 2024" => "IHO P-5 Vol. 2024", # yearbook year IS a volume
      "IHO P-5/2024" => "IHO P-5 Vol. 2024",
      "IHO P-5 2024" => "IHO P-5 Vol. 2024", # the bare year, a legacy alias
      "IHO B-7 2023" => "IHO B-7 Vol. 2023",
      "P-5 2024" => "IHO P-5 Vol. 2024",

      # --- the with-year qualifier on standards (the only bare-year-free
      #     year face; parenthesized beside the edition) ---
      "IHO S-100 5.0.0 Part 2 (2024)" => "IHO S-100 5.0.0 Part 2 (2024)",
      "IHO S-100 1.0.0 (2024) Part A" => "IHO S-100 1.0.0 Part A (2024)",

      # colon-separated sub-publication and the optional IHO prefix
      "IHO S-158:100 1.0.0" => "IHO S-158:100 1.0.0",
      "IHO S-158:100 Part 2 1.0.0" => "IHO S-158:100 1.0.0 Part 2",
      "S-44 5.0.0" => "IHO S-44 5.0.0",
      "S-66 Sup 1 1.0.0" => "IHO S-66 1.0.0 Sup 1",
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

    # A two-segment tail is deliberately not a discriminator: no IHO
    # series carries one in the corpus, and neither new rule swallows it
    # (a volume needs the Vol./slash form or a 19xx/20xx year; a dotted
    # edition needs all three segments).
    it "raises on a two-segment tail" do
      expect do
        Pubid::Iho.parse("IHO B-12 3.0")
      end.to raise_error(Pubid::Errors::ParseError)
    end

    # A number with no separator before the part stays a whole number —
    # the ambiguity that banned the glued numeric shorthand.
    it "parses S-1001 as the whole series number" do
      expect(Pubid::Iho.parse("IHO S-1001").number).to eq("1001")
      expect(Pubid::Iho.parse("IHO S-1001").part).to be_nil
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

  describe "every component is first-class" do
    # Owner ruling: "FULLY encompassing of all of these components
    # semantically" — each is a typed attribute, independently
    # addressable, not a string suffix.
    it "exposes edition, part, annex on one identifier" do
      id = Pubid::Iho.parse("IHO S-98 1.0.0 Part A Annex B")
      expect(id.edition).to eq("1.0.0")
      expect(id.part).to eq("A")
      expect(id.annex).to eq("B")
    end

    it "exposes appendix and its subnumber separately" do
      id = Pubid::Iho.parse("IHO S-122 1.0.0 Appendix D-2")
      expect(id.appendix).to eq("D")
      expect(id.appendix_subnumber).to eq("2")
    end

    it "exposes supplement and volume/issue" do
      id = Pubid::Iho.parse("IHO P-1 Vol. 30 (2)")
      expect(id.volume).to eq("30")
      expect(id.issue).to eq("2")
    end

    it "binds a bare legacy year into the volume, not the year" do
      id = Pubid::Iho.parse("IHO P-5 2024")
      expect(id.volume).to eq("2024")
      expect(id.year).to be_nil
    end

    it "keeps the with-year qualifier on year, beside the edition" do
      id = Pubid::Iho.parse("IHO S-100 5.0.0 Part 2 (2024)")
      expect(id.year).to eq("2024")
      expect(id.edition).to eq("5.0.0")
      expect(id.volume).to be_nil
    end

    it "pads the v-edition shorthand into the dotted edition" do
      expect(Pubid::Iho.parse("IHO S-100 v5.1").edition).to eq("5.1.0")
    end

    it "never puts a year on an edition-keyed identifier" do
      id = Pubid::Iho.parse("IHO S-100 1.0.0")
      expect(id.edition).to eq("1.0.0")
      expect(id.year).to be_nil
    end
  end

  describe "key_value serialization" do
    # Used by the relaton index: each id is stored as #to_hash and rebuilt via
    # .from_hash, so the round-trip must be lossless and the hash must be lean.
    [
      "IHO S-100 5.2.0",
      "IHO S-100 1.0.0 Part 4b",
      "IHO S-122 1.0.0 Appendix D-2",
      "IHO S-100 5.2.0 Annex A",
      "IHO S-66 2.0.0 Sup 1",
      "IHO M-2 Sup 3",
      "IHO B-1 1.0.0",
      "IHO P-1 1.0.0 Vol. 21",
      "IHO M-3 2.0.0",
      "IHO C-13 1.0.0",
      "IHO B-12 3.0.0",
      "IHO P-5 Vol. 2024",
      "IHO P-1 Vol. 30 (2)",
      "IHO S-100 5.0.0 Part 2 (2024)",
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

  describe "matching semantics" do
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

    # The appendix subnumber is the appendix's scalar sibling.
    it "nils the appendix/subnumber cluster on exclude(:appendix)" do
      sub = Pubid::Iho.parse("IHO S-122 1.0.0 Appendix D-2")
      plain = Pubid::Iho.parse("IHO S-122 1.0.0 Appendix D")
      excluded = sub.exclude(:appendix)
      expect(excluded.appendix).to be_nil
      expect(excluded.appendix_subnumber).to be_nil
      expect(excluded).to eq(plain.exclude(:appendix))
    end

    # A lone scalar year needs no override: the base nils a declared
    # :year directly (the additive :year -> :date alias).
    it "nils the year qualifier on exclude(:year)" do
      expect(Pubid::Iho.parse("IHO S-100 5.0.0 (2024)").exclude(:year).year)
        .to be_nil
    end
  end

  describe "compact faces" do
    {
      "IHO M-2 Sup 2" => "IHO M-2-2",
      "IHO S-5 Part B" => "IHO S-5-B",
      "IHO S-100 5.0.0 Part 2" => "IHO S-100-2 5.0.0",
      "IHO P-5 Vol. 2024" => "IHO P-5/2024",
      "IHO P-1 Vol. 30 (2)" => "IHO P-1/30 (2)",
    }.each do |canonical, compact|
      it "renders #{canonical.inspect} compactly as #{compact.inspect}" do
        expect(Pubid::Iho.parse(canonical).to_s(compact: true)).to eq(compact)
      end
    end

    it "keeps the canonical face unless compact is requested" do
      expect(Pubid::Iho.parse("IHO S-5 Part B").to_s).to eq("IHO S-5 Part B")
    end
  end
end
