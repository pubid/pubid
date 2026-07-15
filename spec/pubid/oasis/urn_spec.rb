# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/oasis"

RSpec.describe "OASIS URN Generation" do
  describe "#to_urn" do
    it "generates a urn:oasis: URN carrying the slug" do
      id = Pubid::Oasis.parse("OASIS OSLC-CoreShapes-3.0-PS01-Pt8")
      urn = id.to_urn
      expect(urn).to eq("urn:oasis:OSLC-CoreShapes-3.0-PS01-Pt8")
    end

    it "follows the urn: format for a bare spec" do
      id = Pubid::Oasis.parse("OASIS amqp-core")
      expect(id.to_urn).to eq("urn:oasis:amqp-core")
    end

    it "percent-encodes space and ] so a malformed slug stays well-formed" do
      ["OASIS CTAS-v3.0]-PS01", "OASIS ECF v4.01"].each do |ref|
        urn = Pubid::Oasis.parse(ref).to_urn
        expect(urn).not_to match(/[ \]]/)
        expect(Pubid::Oasis::UrnParser.parse(urn).to_s).to eq(ref)
      end
    end
  end
end
