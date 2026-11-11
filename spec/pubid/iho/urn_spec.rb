# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Iho::UrnGenerator do
  # The positional segment grammar (documented in the grammar header and
  # the flavor notes): containment-ordered, one semantic atom per
  # segment, marker = the lowercased face token.
  describe "#generate" do
    {
      "IHO S-100" => "urn:iho:s:100", # undated: no date segment
      "IHO S-44 5.0.0" => "urn:iho:s:44:ed-5.0.0",
      "IHO S-98 1.0.0 Part A" => "urn:iho:s:98:ed-1.0.0:part-A",
      "IHO S-100 1.0.0 Part 4a" => "urn:iho:s:100:ed-1.0.0:part-4a",
      "IHO S-65 1.2.0 Annex B" => "urn:iho:s:65:ed-1.2.0:annex-B",
      "IHO S-122 1.0.0 Appendix D-2" => "urn:iho:s:122:ed-1.0.0:appendix-D:2",
      "IHO S-52 4.0.0 Appendix 1" => "urn:iho:s:52:ed-4.0.0:appendix-1",
      "IHO M-2 Sup 1" => "urn:iho:m:2:sup-1",
      "IHO S-66 2.0.0 Sup 4" => "urn:iho:s:66:ed-2.0.0:sup-4",
      "IHO P-1/21 1.0.0" => "urn:iho:p:1:vol-21:ed-1.0.0",
      # serial locators: the yearbook year IS a volume — no year segment
      "IHO P-5 Vol. 2024" => "urn:iho:p:5:vol-2024",
      "IHO P-1 Vol. 30" => "urn:iho:p:1:vol-30",
      "IHO P-1 Vol. 30 (2)" => "urn:iho:p:1:vol-30:issue-2",
      # the standards with-year qualifier keeps its own segment
      # the base year qualifier emits beside the base edition
      "IHO S-100 5.0.0 Part 2 (2024)" =>
        "urn:iho:s:100:ed-5.0.0:year-2024:part-2",
      # component editions: the ed- segment attaches to the node it
      # follows (the separately-published mode)
      "IHO P-6 Vol. 2 1.0.1" => "urn:iho:p:6:vol-2:ed-1.0.1",
      "IHO S-98 Part A 1.0.0 (2024)" =>
        "urn:iho:s:98:part-A:ed-1.0.0:year-2024",
      "IHO S-158 Part S-102 0.2.0" => "urn:iho:s:158:part-S-102:ed-0.2.0",
      "IHO P-6 1.0.0 Vol. 2" => "urn:iho:p:6:ed-1.0.0:vol-2",
      # the number keeps its colon; no component segment can collide
      # with it, so a colon number and a volume stay distinct
      "IHO S-158:100" => "urn:iho:s:158:100",
      "IHO S-158:100 1.0.0" => "urn:iho:s:158:100:ed-1.0.0",
      "IHO S-158 Vol. 2024" => "urn:iho:s:158:vol-2024",
      "IHO M-3 2.0.0" => "urn:iho:m:3:ed-2.0.0",
      "IHO B-4 2.19.0" => "urn:iho:b:4:ed-2.19.0",
      "IHO C-13 1.0.0" => "urn:iho:c:13:ed-1.0.0",
    }.each do |input, urn|
      it "renders #{input.inspect} as #{urn.inspect}" do
        expect(Pubid::Iho.parse(input).to_urn).to eq(urn)
      end
    end

    it "gives different URNs to a colon number and a volume" do
      expect(Pubid::Iho.parse("IHO S-158:2024").to_urn)
        .not_to eq(Pubid::Iho.parse("IHO S-158 Vol. 2024").to_urn)
    end
  end

  # The S-4 loose-leaf spec citation (pubid#691): the citation letter
  # rides the part- atom (case preserved: part-B), the spec number and
  # its sub/variant are the atoms after it, and the SECTION is never
  # emitted — it is the spec number's hundreds digit, derivable.
  describe "S-4 spec citations" do
    {
      "IHO S-4 B-401" => "urn:iho:s:4:part-B:spec-401",
      "IHO S-4 4.10.0 B-401" => "urn:iho:s:4:ed-4.10.0:part-B:spec-401",
      "IHO S-4 B-122.1" => "urn:iho:s:4:part-B:spec-122:specsub-1",
      "IHO S-4 B-521(I)" => "urn:iho:s:4:part-B:spec-521:specvar-I",
      "IHO S-4 B-351.1(I)" => "urn:iho:s:4:part-B:spec-351:specsub-1:specvar-I",
      "IHO S-4 B-400" => "urn:iho:s:4:part-B:spec-400", # the section-level slot
      "IHO S-4 B-170" => "urn:iho:s:4:part-B:spec-170", # reserved
      # the loose forms are the same identity: one URN
      "B-401" => "urn:iho:s:4:part-B:spec-401",
      "S-4 Part B, Section 400" => "urn:iho:s:4:part-B:spec-400",
      "S-4 Part B, Section 400, B-401" => "urn:iho:s:4:part-B:spec-401",
    }.each do |input, urn|
      it "renders #{input.inspect} as #{urn.inspect}" do
        expect(Pubid::Iho.parse(input).to_urn).to eq(urn)
      end
    end

    it "emits no section atom" do
      expect(Pubid::Iho.parse("IHO S-4 B-401").to_urn).not_to include("section")
    end
  end
end
