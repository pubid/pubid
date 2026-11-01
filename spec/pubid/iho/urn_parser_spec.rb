# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/iho"
require_relative "../../support/urn_round_trip"

RSpec.describe Pubid::Iho::UrnParser do
  it_behaves_like "flavor URN round-trip", Pubid::Iho, [
    "IHO S-44 5.0.0",
    "IHO S-100 Part 4a 1.0.0",
    "IHO S-65 Ap. A 1.0.0",
    "IHO S-100 Annex A 5.2.0",
    "IHO S-66 Suppl 1 2.0.0",
    "IHO P-5 2024",
    "IHO B-7 2023",
    "IHO P-1 Vol. 30",
    "IHO P-1 Vol. 30 (2)",
    "IHO S-158:100",
    "IHO S-158:100 1.0.0",
    "IHO S-158:100 Part 2 1.0.0",
    "IHO S-158:2024",
    "IHO S-158 2024",
  ]

  # The URN does not escape the colon of a number such as S-158:100,
  # so every untagged segment before the version belongs to the
  # number, and a year is always tagged (y.N).
  {
    "urn:iho:s:158:100" => "IHO S-158:100",
    "urn:iho:s:158:100:1.0.0" => "IHO S-158:100 1.0.0",
    "urn:iho:s:158:100:part.2:1.0.0" => "IHO S-158:100 Part 2 1.0.0",
    "urn:iho:s:158:2024" => "IHO S-158:2024",
    "urn:iho:s:158:y.2024" => "IHO S-158 2024",
    "urn:iho:p:5:y.2024" => "IHO P-5 2024",
    "urn:iho:p:1:vol.30:issue.2" => "IHO P-1 Vol. 30 (2)",
  }.each do |urn, text|
    it "decodes #{urn.inspect} as #{text.inspect}" do
      expect(described_class.new.parse_urn(urn).to_s).to eq(text)
    end
  end

  it "gives different URNs to a colon number and a year" do
    expect(Pubid::Iho.parse("IHO S-158:2024").to_urn)
      .not_to eq(Pubid::Iho.parse("IHO S-158 2024").to_urn)
  end
end
