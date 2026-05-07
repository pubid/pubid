# frozen_string_literal: true

require "spec_helper"
require_relative "../../../lib/pubid/cie/scheme"

RSpec.describe Pubid::Cie::SingleIdentifier do
  describe "inheritance" do
    it "inherits from Identifier" do
      std = Pubid::Cie::Identifiers::Standard.new(code: "1")
      expect(std).to be_a(described_class)
      expect(std).to be_a(Pubid::Cie::Identifier)
    end
  end

  describe "attributes" do
    it "has year attribute" do
      std = Pubid::Cie::Identifiers::Standard.new(code: "1", year: "2020")
      expect(std.year).to eq("2020")
    end

    it "has date_separator attribute" do
      std = Pubid::Cie::Identifiers::Standard.new(code: "1",
                                                  date_separator: "colon")
      expect(std.date_separator).to eq("colon")
    end
  end
end
