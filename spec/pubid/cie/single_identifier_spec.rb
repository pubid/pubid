# frozen_string_literal: true

require "spec_helper"
require "pubid"

RSpec.describe Pubid::Cie::SingleIdentifier do
  describe "inheritance" do
    it "inherits from Identifier" do
      std = Pubid::Cie::Identifiers::Standard.new(number: "1")
      expect(std).to be_a(described_class)
      expect(std).to be_a(Pubid::Cie::Identifier)
    end
  end

  describe "attributes" do
    it "has year attribute" do
      std = Pubid::Cie::Identifiers::Standard.new(number: "1", year: "2020")
      expect(std.year).to eq("2020")
    end

    it "derives the year separator from style" do
      expect(Pubid::Cie::Identifiers::Standard.new(style: "current").date_sep_char).to eq(":")
      expect(Pubid::Cie::Identifiers::Standard.new(style: "legacy").date_sep_char).to eq("-")
      expect(Pubid::Cie::Identifiers::Standard.new(style: "slash").date_sep_char).to eq("/")
    end
  end
end
