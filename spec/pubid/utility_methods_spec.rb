# frozen_string_literal: true

require "rspec"
require_relative "../../lib/pubid/iso"

RSpec.describe "Pubid Utility Methods" do
  describe "#exclude" do
    it "excludes year from identifier" do
      id = Pubid::Iso.parse("ISO 9001:2015")
      excluded = id.exclude(:year)
      expect(excluded.to_s).to eq("ISO 9001")
    end

    it "excludes part from identifier" do
      id = Pubid::Iso.parse("ISO 8601-1:2019")
      excluded = id.exclude(:part)
      expect(excluded.to_s).to eq("ISO 8601:2019")
    end

    it "excludes multiple attributes" do
      id = Pubid::Iso.parse("ISO 8601-1:2019")
      excluded = id.exclude(:part, :year)
      expect(excluded.to_s).to eq("ISO 8601")
    end

    it "returns new identifier without modifying original" do
      id = Pubid::Iso.parse("ISO 9001:2015")
      excluded = id.exclude(:year)
      expect(id.to_s).to eq("ISO 9001:2015")
      expect(excluded.to_s).to eq("ISO 9001")
    end

    it "handles identifier with supplement" do
      id = Pubid::Iso.parse("ISO 9001:2015/Amd 1:2020")
      excluded = id.exclude(:supplements)
      expect(excluded.to_s).to eq("ISO 9001:2015")
    end
  end

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
      expect do
        id2.new_edition_of?(id1)
      end.to raise_error(ArgumentError,
                         /Cannot compare edition/)
    end

    it "handles documents with parts" do
      id1 = Pubid::Iso.parse("ISO 8601-1:2015")
      id2 = Pubid::Iso.parse("ISO 8601-1:2019")
      expect(id2.new_edition_of?(id1)).to be true
    end

    it "raises error for different parts" do
      id1 = Pubid::Iso.parse("ISO 8601-1:2015")
      id2 = Pubid::Iso.parse("ISO 8601-2:2015")
      expect do
        id2.new_edition_of?(id1)
      end.to raise_error(ArgumentError,
                         /Cannot compare edition/)
    end
  end

  describe "#root" do
    it "returns base for amendment" do
      id = Pubid::Iso.parse("ISO 9001:2015/Amd 1:2020")
      expect(id.root.to_s).to eq("ISO 9001:2015")
    end

    it "returns base for corrigendum" do
      id = Pubid::Iso.parse("ISO 9001:2015/Cor 1:2020")
      expect(id.root.to_s).to eq("ISO 9001:2015")
    end

    it "returns base for nested supplements" do
      id = Pubid::Iso.parse("ISO 9001:2015/Amd 1:2020/Cor 1:2021")
      expect(id.root.to_s).to eq("ISO 9001:2015")
    end

    it "returns self for base identifier" do
      id = Pubid::Iso.parse("ISO 9001:2015")
      expect(id.root).to eq(id)
      expect(id.root.to_s).to eq("ISO 9001:2015")
    end

    it "handles addendum" do
      id = Pubid::Iso.parse("ISO 9001:2015/Add 1:2020")
      expect(id.root.to_s).to eq("ISO 9001:2015")
    end
  end
end
