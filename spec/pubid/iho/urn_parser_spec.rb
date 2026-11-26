# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/iho"
require_relative "../../support/urn_round_trip"

RSpec.describe Pubid::Iho::UrnParser do
  # parse -> to_urn -> parse must preserve every component, for plain
  # and nested (containment) shapes alike.
  it_behaves_like "flavor URN round-trip", Pubid::Iho, [
    "IHO S-44 5.0.0",
    "IHO S-100 5.0.0 Part 2",
    "IHO S-98 1.0.0 Part A Annex A",
    "IHO S-122 1.0.0 Appendix D-2",
    "IHO S-52 4.0.0 Appendix 1",
    "IHO S-66 2.0.0 Sup 4",
    "IHO M-2 Sup 1",
    "IHO P-5 Vol. 2024",
    "IHO P-1 Vol. 30",
    "IHO P-1 Vol. 30 (2)",
    "IHO P-1 1.0.0 Vol. 21",
    "IHO S-100 5.0.0 Part 2 (2024)",
    "IHO S-158:100",
    "IHO S-158:100 1.0.0",
    "IHO S-158:100 Part 2 1.0.0",
    "IHO S-158:102 1.0.0",
    "IHO S-158 1.0.0",
    "IHO S-158:2024",
    "IHO S-158 Vol. 2024",
    "IHO S-100",
  ]

  # --- the adopted IHO MRN guidance form (the emission of every
  #     series; the B/C codes cite S-11 Part C Ed 1.0.0 section 1.2) ---
  {
    "urn:mrn:iho:pub:spec:s44:5.0.0" => "IHO S-44 5.0.0",
    "urn:mrn:iho:pub:spec:s158:1.0.0" => "IHO S-158 1.0.0", # the framework
    "urn:mrn:iho:pub:spec:s158-102:1.0.0" => "IHO S-158:102 1.0.0",
    "urn:mrn:iho:pub:spec:s158-100" => "IHO S-158:100",
    "urn:mrn:iho:pub:spec:s158-100:part-2:ed-1.0.0" =>
      "IHO S-158:100 Part 2 1.0.0",
    "urn:mrn:iho:pub:reg:m2:sup-1" => "IHO M-2 Sup 1",
    "urn:mrn:iho:pub:per:p1:vol-30:issue-2" => "IHO P-1 Vol. 30 (2)",
    "urn:mrn:iho:pub:spec:s100:5.0.0:year-2024:part-2" =>
      "IHO S-100 5.0.0 Part 2 (2024)",
    # the compound appendix segment (the subnumber hyphen-joins)
    "urn:mrn:iho:pub:spec:s122:1.0.0:appendix-D-2" =>
      "IHO S-122 1.0.0 Appendix D-2",
    "urn:mrn:iho:pub:spec:s4:4.10.0:part-B:spec-401" =>
      "IHO S-4 4.10.0 B-401",
    "urn:mrn:iho:pub:spec:s98:part-A:ed-1.0.0:year-2024" =>
      "IHO S-98 Part A 1.0.0 (2024)",
    # the guidance's name form: lowercase, dotted edition
    "urn:mrn:iho:pub:spec:s98:1.0.0" => "IHO S-98 1.0.0",
    # the bathy (B) and cb (C) codes: S-11 Part C Ed 1.0.0 section 1.2
    # groups ("B - Bathymetric Publications", "C - Capacity Building
    # Publications") onto the guidance codes; the receipts are the
    # testsuite corpus rows (B-12 CSB Guidance, C-13 Manual on
    # Hydrography, C-51 6.0.0)
    "urn:mrn:iho:pub:bathy:b12:3.0.0" => "IHO B-12 3.0.0",
    "urn:mrn:iho:pub:bathy:b4:2.19.0" => "IHO B-4 2.19.0",
    "urn:mrn:iho:pub:cb:c13:1.0.0" => "IHO C-13 1.0.0",
    "urn:mrn:iho:pub:cb:c51:6.0.0" => "IHO C-51 6.0.0",
    "urn:mrn:iho:pub:bathy:b7:vol-2023" => "IHO B-7 Vol. 2023",
  }.each do |urn, text|
    it "decodes #{urn.inspect} as #{text.inspect}" do
      expect(described_class.new.parse_urn(urn).to_s).to eq(text)
    end
  end

  # --- the legacy positional form (decode-only for every series,
  #     emitted by none) ---
  {
    "urn:iho:s:158:100" => "IHO S-158:100",
    "urn:iho:s:158:100:ed-1.0.0" => "IHO S-158:100 1.0.0",
    "urn:iho:s:158:100:part-2:ed-1.0.0" => "IHO S-158:100 Part 2 1.0.0",
    "urn:iho:s:158:2024" => "IHO S-158:2024",
    "urn:iho:s:158:vol-2024" => "IHO S-158 Vol. 2024",
    "urn:iho:s:122:ed-1.0.0:appendix-D:2" => "IHO S-122 1.0.0 Appendix D-2",
    "urn:iho:p:5:vol-2024" => "IHO P-5 Vol. 2024",
    "urn:iho:p:1:vol-30:issue-2" => "IHO P-1 Vol. 30 (2)",
    "urn:iho:s:100:ed-5.0.0:part-2:year-2024" =>
      "IHO S-100 5.0.0 Part 2 (2024)",
    "urn:iho:m:2:sup-1" => "IHO M-2 Sup 1",
    # the positional ed- attach: a component edition lands on its
    # component, a bare base edition on the base
    "urn:iho:p:6:vol-2:ed-1.0.1" => "IHO P-6 Vol. 2 1.0.1",
    "urn:iho:p:6:ed-1.0.0:vol-2" => "IHO P-6 1.0.0 Vol. 2",
    # the draft-era part-S-102 URN decodes to the product identity
    # through the shared builder unification (issue #774); the render
    # keeps the Part face only on the parse path — a URN decode renders
    # the canonical colon designator
    "urn:iho:s:158:part-S-102:ed-0.2.0" => "IHO S-158:102 0.2.0",
    "urn:iho:s:98:part-A:ed-1.0.0:year-2024" => "IHO S-98 Part A 1.0.0 (2024)",
    "urn:iho:s:122:appendix-D:2:ed-1.0.0" => "IHO S-122 Appendix D-2 1.0.0",
    "urn:iho:b:4:ed-2.19.0" => "IHO B-4 2.19.0",
  }.each do |urn, text|
    it "decodes legacy #{urn.inspect} as #{text.inspect}" do
      expect(described_class.new.parse_urn(urn).to_s).to eq(text)
    end
  end

  # --- legacy 2.0.x spellings: decodable, never emitted ---
  {
    # the #635/#637 y. year tag: the yearbook year IS a volume, so the
    # value decodes into the volume component (urn:iho:p:5:y.2024 now
    # re-emits as urn:iho:p:5:vol-2024)
    "urn:iho:p:5:y.2024" => "IHO P-5 Vol. 2024",
    "urn:iho:s:158:y.2024" => "IHO S-158 Vol. 2024",
    "urn:iho:p:1:vol.30:issue.2" => "IHO P-1 Vol. 30 (2)",
    "urn:iho:s:66:suppl.1:2.0.0" => "IHO S-66 2.0.0 Sup 1",
    "urn:iho:s:65:ap.A:1.0.0" => "IHO S-65 1.0.0 Appendix A",
    "urn:iho:s:100:part.4a:1.0.0" => "IHO S-100 1.0.0 Part 4a",
    "urn:iho:s:100:annex.A:5.2.0" => "IHO S-100 5.2.0 Annex A",
    "urn:iho:b:1:1.0.0" => "IHO B-1 1.0.0", # the bare a.b.c edition
    # the legacy appendix stored the subnumber inside one string
    "urn:iho:s:122:ed-1.0.0:appendix.D-2" => "IHO S-122 1.0.0 Appendix D-2",
  }.each do |urn, text|
    it "decodes legacy #{urn.inspect} as #{text.inspect}" do
      id = described_class.new.parse_urn(urn)
      expect(id.to_s).to eq(text)
    end
  end

  # --- strict positional validation: unknown, malformed or duplicate
  #     segments are rejected, never mis-consumed ---
  {
    "urn:iho:x:100" => "unknown IHO series",
    "urn:iho:s" => "missing docnumber",
    "urn:iho:s:100:junk-segment" => "unexpected segment",
    "urn:iho:s:100:part-A1" => "invalid part value",
    "urn:iho:s:100:annex-BC" => "invalid annex value",
    "urn:iho:s:100:ed-1.0" => "invalid edition value",
    "urn:iho:s:100:year-19" => "invalid year value",
    "urn:iho:s:100:ed-1.0.0:ed-2.0.0" => "duplicate edition segment",
    "urn:iho:s:100:vol-30:vol-31" => "duplicate volume segment",
    "urn:iho:s:100:appendix-D:2:3" => "stray bare atom after the subnumber",
    # the member designator rides the S-158 anchor only (issue #774)
    "urn:iho:s:44:5" => "the product member designator is the S-158 series device",
    # the guidance form: unknown publication type (bathy is one of the
    # five codes now), unknown name, the
    # un-modeled bare correction slot (the s57:3:1 form)
    "urn:mrn:iho:pub:bogus:s44:5.0.0" => "unknown publication type",
    "urn:mrn:iho:pub:spec:x44:5.0.0" => "unknown publication name",
    "urn:mrn:iho:pub:spec:s44-5:1.0.0" => "the product member designator is the S-158 series device",
    "urn:mrn:iho:pub:spec:s57:3:1" => "unexpected segment",
    "urn:mrn:iho:pub:spec:s122:1.0.0:appendix-d-2" =>
      "invalid appendix value", # appendix letters stay case-preserved
  }.each do |urn, reason|
    it "rejects #{urn.inspect} (#{reason})" do
      expect { described_class.new.parse_urn(urn) }
        .to raise_error(Pubid::Errors::UrnParseError)
    end
  end

  # The owner-demanded nested round trips: the containment tree survives
  # parse -> URN -> parse AND parse -> hash -> parse. The URN carries the
  # canonical shape (the draft-era spelling face is a parse-only facet),
  # so the S-158 row cites the colon designator.
  {
    "IHO S-98 1.0.0 Annex A" => %i[edition annex],
    "IHO P-6 Vol. 2 1.0.1" => %i[volume volume_edition],
    "IHO S-158:102 0.2.0" => %i[product edition],
    "IHO S-122 1.0.0 Appendix D-2" => %i[edition appendix appendix_subnumber],
    "IHO S-100 5.0.0 Part 2 (2024)" => %i[edition part year],
    "IHO S-4 4.10.0 B-401" => %i[edition part spec],
    "IHO S-4 B-122.1" => %i[part spec spec_sub],
    "IHO S-4 B-521(I)" => %i[part spec spec_variant],
    "IHO S-4 B-351.1(I)" => %i[part spec spec_sub spec_variant],
    "IHO S-4 B-400" => %i[part spec],
  }.each do |text, components|
    it "round-trips #{text.inspect} through the URN and the hash" do
      id = Pubid::Iho.parse(text)
      from_urn = Pubid::Iho::UrnParser.parse(id.to_urn)
      expect(from_urn.to_s).to eq(id.to_s)
      expect(from_urn.to_urn).to eq(id.to_urn)
      components.each do |component|
        expect(from_urn.public_send(component)).to eq(id.public_send(component))
      end

      from_hash = Pubid::Iho::Identifier.from_hash(id.to_hash)
      expect(from_hash).to eq(id)
      expect(from_hash.to_urn).to eq(id.to_urn)
    end
  end

  # The draft-era spellings survive the hash round-trip too: the
  # unification runs on from_hash, so a stored row carrying the part
  # model decodes to the product identity (issue #774).
  it "unifies the draft-era part model on from_hash" do
    legacy_row = {
      "_type" => "pubid:iho:standard", "number" => "158",
      "part" => "S-102", "part_edition" => "0.2.0",
    }
    from_hash = Pubid::Iho::Identifier.from_hash(legacy_row)
    expect(from_hash.product).to eq("102")
    expect(from_hash.edition).to eq("0.2.0")
    expect(from_hash.part).to be_nil
    expect(from_hash).to eq(Pubid::Iho.parse("IHO S-158:102 0.2.0"))
  end

  describe "the S-4 spec segments (pubid#691)" do
    {
      "urn:iho:s:4:part-B:spec-401" => "IHO S-4 B-401",
      "urn:iho:s:4:ed-4.10.0:part-B:spec-401" => "IHO S-4 4.10.0 B-401",
      "urn:iho:s:4:part-B:spec-122:specsub-1" => "IHO S-4 B-122.1",
      "urn:iho:s:4:part-B:spec-521:specvar-I" => "IHO S-4 B-521(I)",
      "urn:iho:s:4:part-B:spec-351:specsub-1:specvar-I" => "IHO S-4 B-351.1(I)",
      "urn:iho:s:4:part-B:spec-400" => "IHO S-4 B-400",
      "urn:iho:s:4:part-A:spec-401" => "IHO S-4 A-401",
    }.each do |urn, text|
      it "decodes #{urn.inspect} as #{text.inspect}" do
        expect(described_class.new.parse_urn(urn).to_s).to eq(text)
      end
    end

    {
      # the spec vocabulary is the S-4 sections (100-600)
      "urn:iho:s:4:part-B:spec-800" => "invalid spec value",
      # specsub-/specvar- are children of the spec, not free markers
      "urn:iho:s:4:part-B:specvar-I" => "only allowed after spec-",
      "urn:iho:s:4:part-B:spec-401:specsub-1:specsub-2" =>
        "duplicate spec_sub segment",
      # an S-4 spec rides its publication's edition — no ed-/year- inside
      "urn:iho:s:4:part-B:spec-401:ed-1.0.0" =>
        "rides its publication's edition",
      "urn:iho:s:4:ed-4.10.0:part-B:spec-401:year-2024" =>
        "rides its publication's edition",
      # a spec without its part has no citation letter
      "urn:iho:s:4:spec-401" => "lettered Part",
      # the citation letter must be an uppercase S-4 Part letter
      "urn:iho:s:4:part-b:spec-401" => "invalid part value",
      "urn:iho:s:4:part-2:spec-401" => "lettered Part",
    }.each do |urn, reason|
      it "rejects #{urn.inspect} (#{reason})" do
        expect { described_class.new.parse_urn(urn) }
          .to raise_error(Pubid::Errors::UrnParseError)
      end
    end
  end
end
