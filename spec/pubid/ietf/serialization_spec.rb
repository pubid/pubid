# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Pubid::Ietf identifier hash round-trip" do
  cases = {
    "RFC 2119" => "pubid:ietf:rfc",
    "RFC 9110" => "pubid:ietf:rfc",
    "BCP 3" => "pubid:ietf:bcp",
    "STD 66" => "pubid:ietf:std",
    "FYI 1" => "pubid:ietf:fyi",
    "draft-giuliano-treedn-02" => "pubid:ietf:internet-draft",
    "draft-giuliano-treedn" => "pubid:ietf:internet-draft",
    "draft-adams-cast-256" => "pubid:ietf:internet-draft",
  }

  cases.each do |ref, type|
    describe ref do
      let(:identifier) { Pubid::Ietf::Identifier.parse(ref) }
      let(:hash) { identifier.to_hash }

      it "serializes to a non-empty hash" do
        expect(hash).not_to be_empty
      end

      it "carries the #{type} _type" do
        expect(hash["_type"]).to eq(type)
      end

      it "rebuilds an equal identifier from its hash" do
        rebuilt = Pubid::Ietf::Identifier.from_hash(hash)
        expect(rebuilt.to_s).to eq(identifier.to_s)
      end

      it "is idempotent under from_hash(x.to_hash).to_hash" do
        rebuilt = Pubid::Ietf::Identifier.from_hash(hash)
        expect(rebuilt.to_hash).to eq(hash)
      end
    end
  end
end
