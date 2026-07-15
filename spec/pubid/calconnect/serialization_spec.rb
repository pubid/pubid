# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Pubid::Calconnect identifier hash round-trip" do
  refs = [
    "CC 18011:2018",           # bare, no series
    "CC 11001:2024",           # bare
    "CC/DIR 10006:2019",       # with series
    "CC/R 18003:2019",         # report series
    "CC/A 0001:2000",          # zero-padded number
    "CC/Adv 0707.1:2007",      # dot sub-part
    "CC/A 0812-1:2008",        # dash sub-part
    "CC/WD 51017:2024-07-23",  # full ISO date (year/month/day split)
  ]

  refs.each do |ref|
    describe ref do
      let(:identifier) { Pubid::Calconnect::Identifier.parse(ref) }
      let(:hash) { identifier.to_hash }

      it "serializes to a non-empty hash" do
        expect(hash).not_to be_empty
      end

      it "tags the hash with the polymorphic _type" do
        expect(hash["_type"]).to eq("pubid:calconnect:standard")
      end

      it "rebuilds an equal identifier from its hash" do
        rebuilt = Pubid::Calconnect::Identifier.from_hash(hash)
        expect(rebuilt.to_s).to eq(identifier.to_s)
      end

      it "is idempotent under from_hash(to_hash)" do
        rebuilt = Pubid::Calconnect::Identifier.from_hash(hash)
        expect(rebuilt.to_hash).to eq(hash)
      end
    end
  end
end
