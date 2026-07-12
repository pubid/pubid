# frozen_string_literal: true

require "spec_helper"
require "pubid/adobe"

RSpec.describe Pubid::Adobe::Identifier do
  describe ".parse" do
    {
      # TechNote — canonical "Adobe TN" form (preferred going forward).
      "Adobe TN 5014"              => "Adobe TN 5014",
      "Adobe TN5014"               => "Adobe TN 5014",
      "Adobe TN 5902"              => "Adobe TN 5902",
      # TechNote — legacy forms, still accepted for back-compat.
      "Adobe Technical Note #5014" => "Adobe TN 5014",
      "Adobe Technical Note 5014"  => "Adobe TN 5014",
      "ATN5014"                    => "Adobe TN 5014",
      # Publication — canonical "Adobe Publication <slug>" form.
      "Adobe Publication adobe-glyph-list"          => "Adobe Publication adobe-glyph-list",
      "Adobe Publication adobe-japan1-7"            => "Adobe Publication adobe-japan1-7",
      "Adobe Publication adobe-postscript-language" => "Adobe Publication adobe-postscript-language",
      # Publication — bare slug form (back-compat).
      "adobe-glyph-list"           => "Adobe Publication adobe-glyph-list",
      "adobe-japan1-7"             => "Adobe Publication adobe-japan1-7",
    }.each do |input, canonical|
      it "parses #{input.inspect} → #{canonical.inspect}" do
        expect(Pubid::Adobe.parse(input).to_s).to eq(canonical)
      end
    end

    it "routes TechNote forms to Identifiers::TechNote" do
      expect(Pubid::Adobe.parse("Adobe TN 5014"))
        .to be_a(Pubid::Adobe::Identifiers::TechNote)
      expect(Pubid::Adobe.parse("ATN5014"))
        .to be_a(Pubid::Adobe::Identifiers::TechNote)
    end

    it "routes slug forms to Identifiers::Publication" do
      expect(Pubid::Adobe.parse("adobe-glyph-list"))
        .to be_a(Pubid::Adobe::Identifiers::Publication)
      expect(Pubid::Adobe.parse("Adobe Publication adobe-glyph-list"))
        .to be_a(Pubid::Adobe::Identifiers::Publication)
    end

    it "captures the tech-note number" do
      expect(Pubid::Adobe.parse("Adobe TN 5014").number).to eq("5014")
    end

    it "captures the publication slug" do
      expect(Pubid::Adobe.parse("Adobe Publication adobe-glyph-list").slug)
        .to eq("adobe-glyph-list")
    end

    it "splits slug-version into separate attributes" do
      pub = Pubid::Adobe.parse("Adobe Publication adobe-japan1-7")
      expect(pub.slug).to eq("adobe-japan1")
      expect(pub.version).to eq("7")
    end

    it "raises on unparseable input" do
      expect { Pubid::Adobe.parse("XYZ123-BAD!!!") }.to raise_error(StandardError)
    end
  end

  describe "#to_urn" do
    {
      "Adobe TN 5014"                             => "urn:adobe:tech-note:5014",
      "ATN5902"                                   => "urn:adobe:tech-note:5902",
      "Adobe Publication adobe-glyph-list"        => "urn:adobe:publication:adobe-glyph-list",
      "Adobe Publication adobe-japan1-7"          => "urn:adobe:publication:adobe-japan1:v7",
    }.each do |input, urn|
      it "renders #{input.inspect} as #{urn.inspect}" do
        expect(Pubid::Adobe.parse(input).to_urn).to eq(urn)
      end
    end
  end

  describe "URN round-trip" do
    %w[
      urn:adobe:tech-note:5014
      urn:adobe:tech-note:5902
      urn:adobe:publication:adobe-glyph-list
      urn:adobe:publication:adobe-japan1:v7
    ].each do |urn|
      it "round-trips #{urn.inspect} through the parser" do
        id = Pubid::Adobe::UrnParser.parse(urn)
        expect(id.to_urn).to eq(urn)
      end
    end
  end

  describe "polymorphic round-trip via to_hash / from_hash" do
    %w[
      Adobe\ TN\ 5014
      ATN5902
      Adobe\ Publication\ adobe-glyph-list
      Adobe\ Publication\ adobe-japan1-7
    ].each do |code|
      it "round-trips #{code.inspect}" do
        id = Pubid::Adobe.parse(code)
        restored = Pubid::Adobe::Identifier.from_hash(id.to_hash)
        expect(restored.to_s).to eq(id.to_s)
        expect(restored.class).to eq(id.class)
      end
    end
  end

  describe "Pubid.prefixes" do
    it "includes Adobe and ATN tokens" do
      expect(Pubid.prefixes(:adobe)).to include("Adobe", "ATN")
    end
  end
end
