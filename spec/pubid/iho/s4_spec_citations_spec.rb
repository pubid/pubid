# frozen_string_literal: true

require "spec_helper"

# The S-4 loose-leaf section and spec citations (pubid#691, owner
# rulings of 2026-11-11). One component, not two tiers: the spec number
# IS the leaf — `B-401` binds the letter into `part` and the number into
# `spec`; the section (the hundreds digit) is a derived reader, never
# stored or emitted, and the `00` slot (B-400) IS the section-level
# citation. LONG AND SHORT FORMS BOTH PARSE: the canonical compact face
# is byte-exact; the long ("Part B, Section 400") and bare ("B-401")
# forms are normalizing parses of the same identity.
RSpec.describe "IHO S-4 spec citations" do
  describe "canonical faces (byte-exact)" do
    {
      "IHO S-4 B-401" => "IHO S-4 B-401",
      # the edition precedes the citation, as it precedes the part
      "IHO S-4 4.10.0 B-401" => "IHO S-4 4.10.0 B-401",
      "IHO S-4 B-122.1" => "IHO S-4 B-122.1",
      "IHO S-4 B-521(I)" => "IHO S-4 B-521(I)",
      "IHO S-4 B-351.1(I)" => "IHO S-4 B-351.1(I)", # sub + variant combine
      "IHO S-4 B-400" => "IHO S-4 B-400", # the section-level citation
      "IHO S-4 B-170" => "IHO S-4 B-170", # reserved, never invalid
    }.each do |input, canonical|
      it "parses and renders #{input.inspect}" do
        expect(Pubid::Iho.parse(input).to_s).to eq(canonical)
      end
    end
  end

  describe "long and bare forms parse to the same identity (loose forms)" do
    {
      "B-401" => "IHO S-4 B-401", # the implicit S-4 anchor
      "IHO B-401" => "IHO S-4 B-401", # publisher + bare citation
      "B-122.1" => "IHO S-4 B-122.1",
      "B-521(I)" => "IHO S-4 B-521(I)",
      "S-4 Part B, Section 400" => "IHO S-4 B-400",
      "IHO S-4 Part B, Section 400" => "IHO S-4 B-400",
      "S-4 Part B, Section 400, B-401" => "IHO S-4 B-401",
    }.each do |input, canonical|
      it "normalizes #{input.inspect} to #{canonical.inspect}" do
        expect(Pubid::Iho.parse(input).to_s).to eq(canonical)
      end
    end

    it "makes the bare and anchored parses one identifier" do
      expect(Pubid::Iho.parse("B-401"))
        .to eq(Pubid::Iho.parse("IHO S-4 B-401"))
    end

    it "makes the long and compact section citations one identifier" do
      expect(Pubid::Iho.parse("S-4 Part B, Section 400"))
        .to eq(Pubid::Iho.parse("IHO S-4 B-400"))
    end

    it "makes the trailing-citation long form one with the compact one" do
      trailing =
        Pubid::Iho.parse("IHO S-4 Part B, Section 400, B-401")
      expect(trailing).to eq(Pubid::Iho.parse("IHO S-4 B-401"))
    end
  end

  describe "one component, not two tiers" do
    it "binds the citation letter into part and the number into spec" do
      id = Pubid::Iho.parse("IHO S-4 B-401")
      expect(id.part).to eq("B")
      expect(id.spec).to eq("401")
      expect(id.spec_sub).to be_nil
      expect(id.spec_variant).to be_nil
    end

    it "keeps the dotted sub and the variant in their own components" do
      id = Pubid::Iho.parse("IHO S-4 B-351.1(I)")
      expect(id.spec).to eq("351")
      expect(id.spec_sub).to eq("1")
      expect(id.spec_variant).to eq("I")
    end

    it "derives the spec part from the part letter" do
      expect(Pubid::Iho.parse("IHO S-4 B-401").spec_part).to eq("B")
      # a Part without a citation is not a spec part
      expect(Pubid::Iho.parse("IHO S-98 Part A").spec_part).to be_nil
    end

    it "derives the section from the hundreds digit, never stores it" do
      expect(Pubid::Iho.parse("IHO S-4 B-401").spec_section).to eq("400")
      expect(Pubid::Iho.parse("IHO S-4 B-122.1").spec_section).to eq("100")
      # the section-level citation derives its own section
      expect(Pubid::Iho.parse("IHO S-4 B-400").spec_section).to eq("400")
      expect(Pubid::Iho.parse("IHO S-44 5.0.0").spec_section).to be_nil
    end

    it "does not grow a section attribute on the hash" do
      expect(Pubid::Iho.parse("IHO S-4 B-401").to_hash.keys)
        .not_to include("spec_section", "spec_part")
    end

    it "round-trips losslessly through to_hash/from_hash" do
      id = Pubid::Iho.parse("IHO S-4 B-351.1(I)")
      expect(Pubid::Iho::Identifier.from_hash(id.to_hash)).to eq(id)
    end
  end

  describe "the anchor is load-bearing" do
    it "refuses a citation on another series" do
      expect { Pubid::Iho.parse("IHO S-100 B-401") }
        .to raise_error(ArgumentError, /requires the S-4 anchor/)
    end

    it "refuses a citation whose letter conflicts with the Part capture" do
      expect { Pubid::Iho.parse("IHO S-4 Part A B-401") }
        .to raise_error(ArgumentError, /conflicts with part A/)
    end

    it "refuses a spelled section that disagrees with the citation" do
      expect { Pubid::Iho.parse("IHO S-4 Part B, Section 500, B-401") }
        .to raise_error(ArgumentError, /disagrees with the citation B-401/)
    end

    it "refuses a numbered part under the long form" do
      expect { Pubid::Iho.parse("IHO S-4 Part 2, Section 400") }
        .to raise_error(ArgumentError, /lettered Part/)
    end

    it "refuses a part edition on a citation" do
      expect { Pubid::Iho.parse("IHO S-4 Part B 1.0.0, Section 400") }
        .to raise_error(ArgumentError, /not a part edition/)
    end

    it "rejects spec-less shapes that are not citations" do
      expect { Pubid::Iho.parse("IHO S-4 B-40") }
        .to raise_error(Pubid::Errors::ParseError)
      expect { Pubid::Iho.parse("IHO S-4 B-800") }
        .to raise_error(Pubid::Errors::ParseError)
    end

    it "keeps the B Bibliographic series on the main branch" do
      id = Pubid::Iho.parse("IHO B-12 3.0.0")
      expect(id).to be_a(Pubid::Iho::Identifiers::Bibliographic)
      expect(id.spec).to be_nil
      expect(id.to_s).to eq("IHO B-12 3.0.0")
    end
  end

  describe "reserved numbers resolve AS RESERVED, never invalid" do
    it "answers reserved? from the registry" do
      expect(Pubid::Iho.parse("IHO S-4 B-170").reserved?).to be(true)
      expect(Pubid::Iho.parse("IHO S-4 4.10.0 B-170").reserved?).to be(true)
      expect(Pubid::Iho.parse("IHO S-4 4.9.0 B-170").reserved?).to be(true)
      expect(Pubid::Iho.parse("IHO S-4 B-401").reserved?).to be(false)
      expect(Pubid::Iho.parse("IHO S-44 5.0.0").reserved?).to be(false)
    end

    it "answers an edition-less reference from any seeded edition" do
      expect(Pubid::Iho.parse("B-230").reserved?).to be(true)
      expect(Pubid::Iho.parse("B-305").reserved?).to be(true)
      expect(Pubid::Iho.parse("B-323").reserved?).to be(true)
      # B-401 is not reserved in any seeded edition
      expect(Pubid::Iho.parse("B-401").reserved?).to be(false)
    end

    it "keys the registry by edition" do
      # 4.9.0 and 4.10.0 both reserve the four numbers; a future edition
      # that un-reserves one is a one-line registry edit away
      expect(Pubid::Iho::ReservedSpecs.registry.keys)
        .to contain_exactly("4.10.0", "4.9.0")
      expect(Pubid::Iho::ReservedSpecs.registry.fetch("4.10.0"))
        .to eq("B" => %w[170 230 305 323])
    end

    it "carries the registry provenance in the data file" do
      path =
        File.expand_path("../../../data/iho/s4-reserved-specs.yaml", __dir__)
      header = File.readlines(path).first(12).join
      expect(header).to include("#691") # the owner's 4.10.0 list
      expect(header).to include("4.9.0") # the verified PDF provenance
    end
  end

  describe "matching semantics" do
    it "nils the spec cluster on exclude(:spec)" do
      sub = Pubid::Iho.parse("IHO S-4 B-351.1(I)")
      plain = Pubid::Iho.parse("IHO S-4 B-351")
      excluded = sub.exclude(:spec)
      expect(excluded.spec).to be_nil
      expect(excluded.spec_sub).to be_nil
      expect(excluded.spec_variant).to be_nil
      expect(excluded).to eq(plain.exclude(:spec))
    end

    it "matches a sub-less reference against a sub-bearing hit" do
      hit = Pubid::Iho.parse("IHO S-4 B-351.1(I)")
      expect(Pubid::Iho.parse("IHO S-4 B-351")
        .matches?(hit, ignore: [:spec])).to be(true)
    end
  end

  describe "faces" do
    it "keeps compact a no-op on the citation (it is already compact)" do
      id = Pubid::Iho.parse("IHO S-4 B-401")
      expect(id.to_s(compact: true)).to eq("IHO S-4 B-401")
    end

    it "renders the citation where the Part face sits" do
      expect(Pubid::Iho.parse("IHO S-4 4.10.0 B-401").to_s)
        .to eq("IHO S-4 4.10.0 B-401")
    end

    it "annotates without raising" do
      expect(Pubid::Iho.parse("IHO S-4 B-122.1").to_s(annotated: true))
        .to include("S-")
    end

    it "drops the publisher on with_publisher: false" do
      expect(Pubid::Iho.parse("IHO S-4 B-401").to_s(with_publisher: false))
        .to eq("S-4 B-401")
    end
  end
end
