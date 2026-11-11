# frozen_string_literal: true

require "spec_helper"

# The IHO wave of the pubid-scheme URN (issue #670). The flavor's own
# rulings are LAW (lib/pubid/iho/CLAUDE.md, the component-model audit):
# containment order, case-preserved parts, the two-level Appendix D-2, the
# unified vol- locator (a yearbook year IS a volume), sup-, and no legacy
# `y.` yearbook marker emitted — its volume carries the year instead. This
# schema bridges those rulings into the shared codec: the same atoms, in
# the containment order of the official URN generator. The official
# urn:mrn:iho:… form stays on #to_urn.
RSpec.describe "IHO pubid-scheme URN" do
  def expect_round_trip(string)
    id = Pubid::Iho.parse(string)
    back = Pubid.parse_urn(id.to_pubid_urn)
    expect(back).to be_a(id.class)
    expect(back.to_hash).to eq(id.to_hash)
    expect(back.to_s).to eq(id.to_s)
  end

  {
    "IHO S-100 5.0.0 Part 2 (2024)" =>
      "urn:pubid:iho:std:100:ed-5.0.0:year-2024:part-2",
    "IHO S-98 1.0.0 Part A" => "urn:pubid:iho:std:98:ed-1.0.0:part-A",
    "IHO S-98 Part D" => "urn:pubid:iho:std:98:part-D",
    "IHO S-122 1.0.0 Appendix D-2" =>
      "urn:pubid:iho:std:122:ed-1.0.0:appendix-D:appsub-2",
    "IHO P-5 Vol. 2024" => "urn:pubid:iho:pub:5:vol-2024",
    "IHO P-1 Vol. 30 (2)" => "urn:pubid:iho:pub:1:vol-30:issue-2",
    "IHO S-66 Sup 4" => "urn:pubid:iho:std:66:sup-4",
    "IHO S-100 Sup 1 2.0.0" => "urn:pubid:iho:std:100:sup-1:suped-2.0.0",
    "IHO S-158 Part S-102 0.2.0" =>
      "urn:pubid:iho:std:158:part-S-102:parted-0.2.0",
    "IHO S-52 Appendix 1 4.0.0" =>
      "urn:pubid:iho:std:52:appendix-1:apped-4.0.0",
    "IHO M-1 2.1.0" => "urn:pubid:iho:m:1:ed-2.1.0",
    "IHO B-1 1.0.0" => "urn:pubid:iho:b:1:ed-1.0.0",
    "IHO C-13 1.0.0" => "urn:pubid:iho:cl:13:ed-1.0.0",
  }.each do |input, urn|
    it "renders #{input} as #{urn}" do
      expect(Pubid::Iho.parse(input).to_pubid_urn).to eq(urn)
    end

    it "round-trips #{input}" do
      expect_round_trip(input)
    end
  end

  it "keeps the yearbook year a volume, so no year atom is emitted" do
    # the legacy `y.` marker is decodable in the official URN parser and
    # never emitted; the periodical locator is vol-<year>
    urn = Pubid::Iho.parse("IHO P-5 Vol. 2024").to_pubid_urn
    expect(urn).not_to include("year-")
    expect(urn).to end_with("vol-2024")
  end

  it "keeps a part letter case-preserved" do
    expect(Pubid::Iho.parse("IHO S-98 1.0.0 Part A").to_pubid_urn)
      .to include("part-A")
  end

  it "does not share the official URN's namespace" do
    expect(Pubid::Iho.parse("IHO S-44 5.0.0").to_urn)
      .to start_with("urn:iho:")
    expect(Pubid::Iho.parse("IHO S-44 5.0.0").to_pubid_urn)
      .to start_with("urn:pubid:iho:")
  end

  # The S-4 loose-leaf spec citation (issue #691): the citation letter
  # rides the part- atom, the spec and its sub/variant are the atoms
  # after it, and the section is never an atom (derivable).
  describe "S-4 spec citations" do
    {
      "IHO S-4 B-401" => "urn:pubid:iho:std:4:part-B:spec-401",
      "IHO S-4 4.10.0 B-401" =>
        "urn:pubid:iho:std:4:ed-4.10.0:part-B:spec-401",
      "IHO S-4 B-122.1" => "urn:pubid:iho:std:4:part-B:spec-122:specsub-1",
      "IHO S-4 B-521(I)" => "urn:pubid:iho:std:4:part-B:spec-521:specvar-I",
      "IHO S-4 B-351.1(I)" =>
        "urn:pubid:iho:std:4:part-B:spec-351:specsub-1:specvar-I",
      "IHO S-4 B-400" => "urn:pubid:iho:std:4:part-B:spec-400",
      "IHO S-4 B-170" => "urn:pubid:iho:std:4:part-B:spec-170",
      "B-401" => "urn:pubid:iho:std:4:part-B:spec-401", # the bare form
      "S-4 Part B, Section 400" => "urn:pubid:iho:std:4:part-B:spec-400",
    }.each do |input, urn|
      it "renders #{input} as #{urn}" do
        expect(Pubid::Iho.parse(input).to_pubid_urn).to eq(urn)
      end

      it "round-trips #{input}" do
        expect_round_trip(input)
      end
    end

    it "emits no section atom for a spec citation" do
      expect(Pubid::Iho.parse("IHO S-4 B-401").to_pubid_urn)
        .not_to include("section")
    end
  end
end
