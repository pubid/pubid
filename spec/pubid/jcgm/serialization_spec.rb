# frozen_string_literal: true

require "spec_helper"
require "pubid/jcgm"

RSpec.describe "JCGM serialization" do
  describe "#to_hash / .from_hash round-trip" do
    {
      "JCGM 17th Meeting (2012)" => "pubid:jcgm:meeting",
      "JCGM 11st Meeting (2006)" => "pubid:jcgm:meeting",
      "JCGM 23rd Meeting (2020)" => "pubid:jcgm:meeting",
      # a guide, to show the mechanism is general (not meeting-specific)
      "JCGM 100:2008" => "pubid:jcgm:guide",
    }.each do |id_str, expected_type|
      describe id_str do
        let(:identifier) { Pubid::Jcgm.parse(id_str) }
        let(:hash) { identifier.to_hash }

        it "produces a non-empty hash" do
          expect(hash).to be_a(Hash)
          expect(hash).not_to be_empty
        end

        it "carries the polymorphic _type #{expected_type.inspect}" do
          expect(hash["_type"]).to eq(expected_type)
        end

        it "rebuilds via from_hash and round-trips to_s" do
          rebuilt = Pubid::Jcgm::Identifier.from_hash(hash)
          expect(rebuilt.to_s).to eq(id_str)
        end

        it "is idempotent under from_hash(to_hash)" do
          rebuilt = Pubid::Jcgm::Identifier.from_hash(hash)
          expect(rebuilt.to_hash).to eq(hash)
        end
      end
    end
  end
end
