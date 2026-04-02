# frozen_string_literal: true

require "rspec"
require_relative "../../lib/pubid/iso"

RSpec.describe Pubid::Identifier do
  describe "#new_edition_of?" do
    it "returns true for newer year" do
      id1 = Pubid::Iso.parse("ISO 9001:2015")
      id2 = Pubid::Iso.parse("ISO 9001:2019")
      expect(id2.new_edition_of?(id1)).to be true
      expect(id1.new_edition_of?(id2)).to be false
    end

    it "returns false for same year" do
      id1 = Pubid::Iso.parse("ISO 9001:2015")
      id2 = Pubid::Iso.parse("ISO 9001:2015")
      expect(id2.new_edition_of?(id1)).to be false
    end

    it "raises error for different documents" do
      id1 = Pubid::Iso.parse("ISO 9001:2015")
      id2 = Pubid::Iso.parse("ISO 9002:2015")
      expect { id2.new_edition_of?(id1) }.to raise_error(ArgumentError, /different number/)
    end

    it "raises error for different parts" do
      id1 = Pubid::Iso.parse("ISO 8601-1:2019")
      id2 = Pubid::Iso.parse("ISO 8601-2:2019")
      expect { id2.new_edition_of?(id1) }.to raise_error(ArgumentError, /different part/)
    end

    it "raises error for undated documents" do
      id1 = Pubid::Iso.parse("ISO 9001")
      id2 = Pubid::Iso.parse("ISO 9001:2015")
      expect { id2.new_edition_of?(id1) }.to raise_error(ArgumentError, /without date/)
    end

    it "compares documents with parts" do
      id1 = Pubid::Iso.parse("ISO 8601-1:2019")
      id2 = Pubid::Iso.parse("ISO 8601-1:2024")
      expect(id2.new_edition_of?(id1)).to be true
    end
  end
end
