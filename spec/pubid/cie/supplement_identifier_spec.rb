# frozen_string_literal: true

require "spec_helper"
require_relative "../../../lib/pubid/cie/scheme"

RSpec.describe Pubid::Cie::SupplementIdentifier do
  describe "inheritance" do
    it "Corrigendum inherits from SupplementIdentifier" do
      cor = Pubid::Cie::Identifiers::Corrigendum.new(
        base_number: "232",
        base_year: "2019",
        cor_number: "1",
        cor_year: "2020",
      )
      expect(cor).to be_a(Pubid::Cie::SupplementIdentifier)
      expect(cor).to be_a(Pubid::Cie::Identifier)
    end

    it "Supplement inherits from SupplementIdentifier" do
      sup = Pubid::Cie::Identifiers::Supplement.new(
        base_number: "121",
        supplement_number: "1",
        year: "2009",
      )
      expect(sup).to be_a(Pubid::Cie::SupplementIdentifier)
      expect(sup).to be_a(Pubid::Cie::Identifier)
    end
  end

  describe "attributes" do
    it "has style attribute" do
      cor = Pubid::Cie::Identifiers::Corrigendum.new(
        base_number: "232",
        base_year: "2019",
        cor_number: "1",
        cor_year: "2020",
        style: "current",
      )
      expect(cor.style).to eq("current")
    end
  end
end
