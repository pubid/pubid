# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Iho::UrnGenerator do
  describe "#generate" do
    {
      "IHO S-44 5.0.0" => "urn:iho:s:44:5.0.0",
      "IHO S-100 Part 4a 1.0.0" => "urn:iho:s:100:part.4a:1.0.0",
      "IHO S-65 Ap. A 1.0.0" => "urn:iho:s:65:ap.A:1.0.0",
      "IHO S-100 Annex A 5.2.0" => "urn:iho:s:100:annex.A:5.2.0",
      "IHO S-66 Suppl 1 2.0.0" => "urn:iho:s:66:suppl.1:2.0.0",
      "IHO P-1/21 1.0.0" => "urn:iho:p:1/21:1.0.0",
      "IHO M-3 2.0.0" => "urn:iho:m:3:2.0.0",
      "IHO B-4 2.19.0" => "urn:iho:b:4:2.19.0",
      "IHO C-13 1.0.0" => "urn:iho:c:13:1.0.0",
      # series components: a year is a y.N tagged segment, a volume
      # (with its optional issue) is a vol.N/issue.N tagged segment
      "IHO P-5 2024" => "urn:iho:p:5:y.2024",
      "IHO B-7 2023" => "urn:iho:b:7:y.2023",
      # the number keeps its colon; a year after it stays tagged, so
      # the two identifiers below get different URNs
      "IHO S-158:2024" => "urn:iho:s:158:2024",
      "IHO S-158 2024" => "urn:iho:s:158:y.2024",
      "IHO P-1 Vol. 30" => "urn:iho:p:1:vol.30",
      "IHO P-1 Vol. 30 (2)" => "urn:iho:p:1:vol.30:issue.2",
    }.each do |input, urn|
      it "renders #{input.inspect} as #{urn.inspect}" do
        expect(Pubid::Iho.parse(input).to_urn).to eq(urn)
      end
    end
  end
end
