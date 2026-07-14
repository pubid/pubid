# frozen_string_literal: true

require "spec_helper"

RSpec.describe "IETF URN generation" do
  {
    "RFC 2119" => "urn:ietf:rfc:2119",
    "BCP 3" => "urn:ietf:bcp:3",
    "STD 66" => "urn:ietf:std:66",
    "FYI 1" => "urn:ietf:fyi:1",
    "draft-giuliano-treedn-02" => "urn:ietf:id:draft-giuliano-treedn:02",
    "draft-giuliano-treedn" => "urn:ietf:id:draft-giuliano-treedn",
  }.each do |ref, urn|
    it "renders #{ref.inspect} as #{urn}" do
      expect(Pubid::Ietf.parse(ref).to_urn).to eq(urn)
    end
  end

  it "starts every URN with urn:ietf:" do
    expect(Pubid::Ietf.parse("RFC 1").to_urn).to start_with("urn:ietf:")
  end
end
