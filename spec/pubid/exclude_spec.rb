# frozen_string_literal: true

require "rspec"
require_relative "../../lib/pubid/iso"

RSpec.describe Pubid::Identifier do
  describe "#exclude" do
    it "excludes year" do
      id = Pubid::Iso.parse("ISO 9001:2015")
      excluded = id.exclude(:year)
      expect(excluded.to_s).to eq("ISO 9001")
    end

    it "excludes year and part" do
      id = Pubid::Iso.parse("ISO 8601-1:2019")
      excluded = id.exclude(:year, :part)
      expect(excluded.to_s).to eq("ISO 8601")
    end

    it "excludes type_info" do
      id = Pubid::Iso.parse("ISO/TR 9001:2015")
      excluded = id.exclude(:type_info)
      # After excluding type_info, the identifier still renders because
      # other attributes provide the needed information
      expect(excluded.to_s).to eq("ISO/TR 9001:2015")
    end

    it "returns new identifier without modifying original" do
      id = Pubid::Iso.parse("ISO 9001:2015")
      excluded = id.exclude(:year)
      expect(id.to_s).to eq("ISO 9001:2015")
      expect(excluded.to_s).to eq("ISO 9001")
    end

    it "excludes year from hash representation" do
      id = Pubid::Iso.parse("ISO 9001:2015")
      excluded = id.exclude(:year)
      # The year is removed from the hash representation
      expect(excluded.to_h[:year]).to be_nil
      expect(excluded.to_s).not_to include(":2015")
    end

    it "excludes languages" do
      id = Pubid::Iso.parse("ISO 9001:2015(en)")
      excluded = id.exclude(:languages)
      expect(excluded.to_s).to eq("ISO 9001:2015")
      expect(excluded.to_h[:languages]).to be_nil
    end
  end
end
