# frozen_string_literal: true

require "spec_helper"

# The S-158 publication-series model (issue #774) and the citation-order
# law (issue #775).
#
# S-158 "Validation Checks — Introduction and Structure" (Ed 1.0.0,
# HSSC17, Feb 2025 —
# https://iho.int/uploads/user/pubs/standards/S-158/S-158_Validation_Checks_Introduction_and_Structure_Ed_1.0.0.pdf)
# is a FRAMEWORK publication defining a series of separate publications
# (clause 2.1), each a publication of its own with its own edition
# stream: S-158:100 (generic checks derived from S-100), S-158:1xx (one
# product-specific check specification per S-100 product — :101 = the
# S-101 ENC checks, :102 = the S-102 Bathymetric Surface checks),
# S-158:98 (interoperability) and S-158:128 (catalogue; Table 6-1).
# `:NNN` is the official IHO product number whose checks the member
# specifies — NOT a part, NOT a "profile".
#
# The wire model: the typed `product` facet; the colon designator
# `S-158:102` is the PRIMARY form; the draft-era spellings (`S-158 Part
# S-102`, `S-158-S-102`, `S-158 Part 102`) are non-normalized aliases of
# the SAME identity — facets-spelling-only (the render keeps the input's
# spelling, equality/URN use the canonical shape), and the URN segment
# order is DECLARATION order, never citation order (issue #775).
RSpec.describe "the S-158 publication series" do
  # The PDF-attested rows. Editions appear only where attested: the PDF
  # itself attests S-158 Ed 1.0.0, and the owner's citation attests
  # S-158:102 1.0.0; the other members' own editions are not attested
  # and stay edition-less.
  {
    "IHO S-158 1.0.0" => "urn:mrn:iho:pub:spec:s158:1.0.0",
    "IHO S-158:100" => "urn:mrn:iho:pub:spec:s158-100",
    "IHO S-158:101" => "urn:mrn:iho:pub:spec:s158-101",
    "IHO S-158:102" => "urn:mrn:iho:pub:spec:s158-102",
    "IHO S-158:102 1.0.0" => "urn:mrn:iho:pub:spec:s158-102:1.0.0",
    "IHO S-158:98" => "urn:mrn:iho:pub:spec:s158-98",
    "IHO S-158:128" => "urn:mrn:iho:pub:spec:s158-128",
  }.each do |input, mrn|
    it "attests #{input.inspect} as #{mrn.inspect}" do
      id = Pubid::Iho.parse(input)
      expect(id.to_urn).to eq(mrn)
    end
  end

  # The owner's citation binds the member, not an opaque number and not
  # a part (the defect receipts of #774/#775).
  it "binds S-158:102 1.0.0 as number=158, product=102" do
    id = Pubid::Iho.parse("S-158:102 1.0.0")
    expect(id.number).to eq("158")
    expect(id.product).to eq("102")
    expect(id.edition).to eq("1.0.0")
    expect(id.part).to be_nil
  end

  describe "one identity, many spellings" do
    let(:spellings) do
      ["IHO S-158:102 0.2.0", "IHO S-158 0.2.0 Part S-102",
       "IHO S-158 Part S-102 0.2.0", "IHO S-158-S-102 0.2.0",
       "IHO S-158 Part 102 0.2.0"]
    end

    it "gives every spelling the same identity" do
      ids = spellings.map { |s| Pubid::Iho.parse(s) }
      expect(ids.uniq.size).to eq(1)
      ids.each do |id|
        expect(id.product).to eq("102")
        expect(id.edition).to eq("0.2.0")
        expect(id.part).to be_nil
        expect(id.part_edition).to be_nil
      end
    end

    it "keeps each spelling's own render" do
      expect(Pubid::Iho.parse("IHO S-158:102 0.2.0").to_s)
        .to eq("IHO S-158:102 0.2.0")
      expect(Pubid::Iho.parse("IHO S-158 Part S-102 0.2.0").to_s)
        .to eq("IHO S-158 0.2.0 Part S-102")
      expect(Pubid::Iho.parse("IHO S-158-S-102 0.2.0").to_s)
        .to eq("IHO S-158 0.2.0 Part S-102")
    end
  end

  # Issue #775, receipt 1: the citation face order must not change the
  # identity or the URN segment order — the canonical order is the
  # DECLARATION order (name, edition, then the components), never the
  # citation order.
  describe "the URN order law" do
    it "emits byte-identical MRNs whatever the citation order" do
      canonical = Pubid::Iho.parse("IHO S-158 0.2.0 Part S-102")
      reordered = Pubid::Iho.parse("IHO S-158 Part S-102 0.2.0")
      expect(reordered).to eq(canonical)
      expect(reordered.to_urn).to eq(canonical.to_urn)
      expect(reordered.to_urn).to eq("urn:mrn:iho:pub:spec:s158-102:0.2.0")
    end

    it "emits byte-identical pubid URNs whatever the citation order" do
      canonical = Pubid::Iho.parse("IHO S-158 0.2.0 Part S-102")
      reordered = Pubid::Iho.parse("IHO S-158 Part S-102 0.2.0")
      expect(reordered.to_pubid_urn).to eq(canonical.to_pubid_urn)
      expect(reordered.to_pubid_urn)
        .to eq("urn:pubid:iho:std:158:product-102:ed-0.2.0")
    end

    it "keeps the edition in its declaration slot for every scheme" do
      id = Pubid::Iho.parse("IHO S-158 Part S-102 0.2.0")
      # edition after the name segment, never a parted- atom
      expect(id.to_urn).to match(/spec:s158-102:0\.2\.0\z/)
      expect(id.to_pubid_urn).to include("product-102:ed-0.2.0")
    end
  end

  # Issue #775, receipt 2: the parted- edition mis-bind is gone — the
  # edition that follows the draft-era part face is the BASE edition.
  it "mis-binds no edition onto the member face" do
    id = Pubid::Iho.parse("IHO S-158 Part S-102 0.2.0")
    expect(id.part_edition).to be_nil
    expect(id.edition).to eq("0.2.0")
    expect(id.to_pubid_urn).not_to include("parted-")
    expect(id.to_urn).not_to include("part-S-102")
  end

  # The transition regression guard: the part-S-102 MRN emission is dead
  # on this family; the legacy form stays decodable and resolves to the
  # same identity.
  it "decodes the legacy part-S-102 MRN onto the checks identity" do
    id = Pubid::Iho::UrnParser.parse("urn:iho:s:158:part-S-102:ed-0.2.0")
    expect(id.product).to eq("102")
    expect(id.to_urn).to eq("urn:mrn:iho:pub:spec:s158-102:0.2.0")
  end

  describe "rejects" do
    # the grammar-level rejects (the malformed colon forms)
    {
      "IHO S-158:" => "the bare colon form",
      "IHO S-158:abc" => "a non-product tail",
    }.each do |input, reason|
      it "rejects #{input.inspect} (#{reason})" do
        expect { Pubid::Iho.parse(input) }
          .to raise_error(Pubid::Errors::ParseError)
      end
    end

    # the builder-level rejects (the semantic anchors)
    {
      "IHO S-44:5" => "the member designator on another anchor",
      "IHO S-158 0.2.0 Part S-102 1.0.0" =>
        "a base edition and a member edition together",
    }.each do |input, reason|
      it "rejects #{input.inspect} (#{reason})" do
        expect { Pubid::Iho.parse(input) }
          .to raise_error(ArgumentError)
      end
    end
  end
end
