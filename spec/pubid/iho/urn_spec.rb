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
      "IHO P-1/21 1.0.0" => "urn:iho:p:1:ed-1.0.0:vol-21",
      # serial locators: the yearbook year IS a volume — no year segment
      "IHO P-5 Vol. 2024" => "urn:iho:p:5:vol-2024",
      "IHO P-1 Vol. 30" => "urn:iho:p:1:vol-30",
      "IHO P-1 Vol. 30 (2)" => "urn:iho:p:1:vol-30:issue-2",
      # the standards with-year qualifier keeps its own segment
      "IHO S-100 5.0.0 Part 2 (2024)" =>
        "urn:iho:s:100:ed-5.0.0:part-2:year-2024",
      # the number keeps its colon; no component segment can collide
      # with it, so a colon number and a volume stay distinct
      "IHO S-158:100" => "urn:iho:s:158:100",
      "IHO S-158:100 1.0.0" => "urn:iho:s:158:100:ed-1.0.0",
      "IHO S-158 Vol. 2024" => "urn:iho:s:158:vol-2024",
      "IHO P-1/21 1.0.0" => "urn:iho:p:1:ed-1.0.0:vol-21",
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
end
