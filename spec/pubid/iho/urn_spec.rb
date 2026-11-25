# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Iho::UrnGenerator do
  # The adopted IHO MRN guidance (S-100WG4, "MRN Guidelines for IHO";
  # owner ruling 2026-11-25): the S/P/M series emit the guidance form —
  # urn:mrn:iho:pub:<type>:<name>[:<dotted edition>][:trailing atoms] —
  # with the lowercase name form (sNNN, the guidance's own s57/s98
  # spelling), the dotted edition in its canonical 4th position, and the
  # containment-ordered trailing atoms. The B/C series have no guidance
  # type code and keep the legacy positional emission.
  describe "#generate" do
    {
      "IHO S-100" => "urn:mrn:iho:pub:spec:s100", # undated: no edition segment
      "IHO S-44 5.0.0" => "urn:mrn:iho:pub:spec:s44:5.0.0",
      "IHO S-98 1.0.0 Part A" => "urn:mrn:iho:pub:spec:s98:1.0.0:part-A",
      "IHO S-100 1.0.0 Part 4a" => "urn:mrn:iho:pub:spec:s100:1.0.0:part-4a",
      "IHO S-65 1.2.0 Annex B" => "urn:mrn:iho:pub:spec:s65:1.2.0:annex-B",
      # the Appendix subnumber hyphen-joins its appendix (one compound segment)
      "IHO S-122 1.0.0 Appendix D-2" =>
        "urn:mrn:iho:pub:spec:s122:1.0.0:appendix-D-2",
      "IHO S-52 4.0.0 Appendix 1" => "urn:mrn:iho:pub:spec:s52:4.0.0:appendix-1",
      # the guidance type per series: S -> spec, M -> reg, P -> per
      "IHO M-2 Sup 1" => "urn:mrn:iho:pub:reg:m2:sup-1",
      "IHO S-66 2.0.0 Sup 4" => "urn:mrn:iho:pub:spec:s66:2.0.0:sup-4",
      "IHO P-1/21 1.0.0" => "urn:mrn:iho:pub:per:p1:vol-21:ed-1.0.0",
      # serial locators: the yearbook year IS a volume — no year segment
      "IHO P-5 Vol. 2024" => "urn:mrn:iho:pub:per:p5:vol-2024",
      "IHO P-1 Vol. 30" => "urn:mrn:iho:pub:per:p1:vol-30",
      "IHO P-1 Vol. 30 (2)" => "urn:mrn:iho:pub:per:p1:vol-30:issue-2",
      # the standards with-year qualifier keeps its own segment; the
      # base year qualifier emits beside the base edition
      "IHO S-100 5.0.0 Part 2 (2024)" =>
        "urn:mrn:iho:pub:spec:s100:5.0.0:year-2024:part-2",
      # component editions: the ed- segment attaches to the node it
      # follows (the separately-published mode)
      "IHO P-6 Vol. 2 1.0.1" => "urn:mrn:iho:pub:per:p6:vol-2:ed-1.0.1",
      "IHO S-98 Part A 1.0.0 (2024)" =>
        "urn:mrn:iho:pub:spec:s98:part-A:ed-1.0.0:year-2024",
      "IHO P-6 1.0.0 Vol. 2" => "urn:mrn:iho:pub:per:p6:1.0.0:vol-2",
      # --- the S-158 series (issue #774): the member joins the name
      #     segment hyphenated, the edition stays in its canonical 4th
      #     position; order-stable across the citation spellings
      "IHO S-158:102 1.0.0" => "urn:mrn:iho:pub:spec:s158-102:1.0.0",
      "IHO S-158 0.2.0 Part S-102" => "urn:mrn:iho:pub:spec:s158-102:0.2.0",
      "IHO S-158 Part S-102 0.2.0" => "urn:mrn:iho:pub:spec:s158-102:0.2.0",
      "IHO S-158-S-102 0.2.0" => "urn:mrn:iho:pub:spec:s158-102:0.2.0",
      "IHO S-158 1.0.0" => "urn:mrn:iho:pub:spec:s158:1.0.0", # the framework
      "IHO S-158:100" => "urn:mrn:iho:pub:spec:s158-100",
      "IHO S-158:100 Part 2 1.0.0" =>
        "urn:mrn:iho:pub:spec:s158-100:part-2:ed-1.0.0",
      "IHO S-158 Vol. 2024" => "urn:mrn:iho:pub:spec:s158:vol-2024",
      # no guidance code for the B/C series: the legacy emission stays
      "IHO M-3 2.0.0" => "urn:mrn:iho:pub:reg:m3:2.0.0",
      "IHO B-4 2.19.0" => "urn:iho:b:4:ed-2.19.0",
      "IHO C-13 1.0.0" => "urn:iho:c:13:ed-1.0.0",
    }.each do |input, urn|
      it "renders #{input.inspect} as #{urn.inspect}" do
        expect(Pubid::Iho.parse(input).to_urn).to eq(urn)
      end
    end

    it "gives different URNs to a member designator and a volume" do
      expect(Pubid::Iho.parse("IHO S-158:2024").to_urn)
        .not_to eq(Pubid::Iho.parse("IHO S-158 Vol. 2024").to_urn)
    end

    it "emits the dotted edition like the guidance's own S-98 metadata" do
      # the printed IHO metadata form: urn:mrn:iho:pub:spec:s98:1.0.0
      expect(Pubid::Iho.parse("IHO S-98 1.0.0").to_urn)
        .to eq("urn:mrn:iho:pub:spec:s98:1.0.0")
    end
  end

  # The S-4 loose-leaf spec citation (pubid#691): the citation letter
  # rides the part- atom (case preserved: part-B), the spec number and
  # its sub/variant are the atoms after it, and the SECTION is never
  # emitted — it is the spec number's hundreds digit, derivable.
  describe "S-4 spec citations" do
    {
      "IHO S-4 B-401" => "urn:mrn:iho:pub:spec:s4:part-B:spec-401",
      "IHO S-4 4.10.0 B-401" =>
        "urn:mrn:iho:pub:spec:s4:4.10.0:part-B:spec-401",
      "IHO S-4 B-122.1" =>
        "urn:mrn:iho:pub:spec:s4:part-B:spec-122:specsub-1",
      "IHO S-4 B-521(I)" =>
        "urn:mrn:iho:pub:spec:s4:part-B:spec-521:specvar-I",
      "IHO S-4 B-351.1(I)" =>
        "urn:mrn:iho:pub:spec:s4:part-B:spec-351:specsub-1:specvar-I",
      "IHO S-4 B-400" => "urn:mrn:iho:pub:spec:s4:part-B:spec-400", # section-level slot
      "IHO S-4 B-170" => "urn:mrn:iho:pub:spec:s4:part-B:spec-170", # reserved
      # the loose forms are the same identity: one URN
      "B-401" => "urn:mrn:iho:pub:spec:s4:part-B:spec-401",
      "S-4 Part B, Section 400" => "urn:mrn:iho:pub:spec:s4:part-B:spec-400",
      "S-4 Part B, Section 400, B-401" =>
        "urn:mrn:iho:pub:spec:s4:part-B:spec-401",
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
