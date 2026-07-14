# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Pubid::Ogc serialization" do
  %w[25-023 24-032r1 01-009a 04-095c1 09-102r3a 12-128r12a].each do |ref|
    context ref do
      let(:identifier) { Pubid::Ogc.parse(ref) }
      let(:hash) { identifier.to_hash }

      it "produces a non-empty hash carrying the polymorphic _type" do
        expect(hash).not_to be_empty
        expect(hash["_type"]).to eq("pubid:ogc:document")
      end

      it "round-trips through from_hash" do
        restored = Pubid::Ogc::Identifier.from_hash(hash)
        expect(restored).to be_a(Pubid::Ogc::Identifiers::Document)
        expect(restored.to_s).to eq(identifier.to_s)
      end

      it "has an idempotent canonical hash" do
        expect(Pubid::Ogc::Identifier.from_hash(hash).to_hash).to eq(hash)
      end
    end
  end

  it "omits the revision key when there is no revision" do
    expect(Pubid::Ogc.parse("25-023").to_hash).not_to have_key("revision")
  end
end
