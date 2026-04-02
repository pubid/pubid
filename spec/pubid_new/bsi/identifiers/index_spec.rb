# frozen_string_literal: true

require_relative "../../../../lib/pubid/bsi"

RSpec.describe Pubid::Bsi::Identifiers::Index do
  describe "parsing" do
    it "parses BS 5000:Index:1981" do
      id = Pubid::Bsi.parse("BS 5000:Index:1981")
      expect(id.class).to eq(Pubid::Bsi::Identifiers::Index)
    end

    it "parses BS 185:Index:1973" do
      id = Pubid::Bsi.parse("BS 185:Index:1973")
      expect(id.class).to eq(Pubid::Bsi::Identifiers::Index)
    end

    it "parses BS 185 Index:1964" do
      id = Pubid::Bsi.parse("BS 185 Index:1964")
      expect(id.class).to eq(Pubid::Bsi::Identifiers::Index)
    end

    it "parses BS 5000 Index Issue 4:1980" do
      id = Pubid::Bsi.parse("BS 5000 Index Issue 4:1980")
      expect(id.class).to eq(Pubid::Bsi::Identifiers::Index)
    end

    it "parses BS 4999 Index Issue 1:1972" do
      id = Pubid::Bsi.parse("BS 4999 Index Issue 1:1972")
      expect(id.class).to eq(Pubid::Bsi::Identifiers::Index)
    end
  end

  describe "rendering" do
    it "renders BS 5000:Index:1981 correctly" do
      id = Pubid::Bsi.parse("BS 5000:Index:1981")
      expect(id.to_s).to eq("BS 5000:Index:1981")
    end

    it "renders BS 185 Index:1964 correctly" do
      id = Pubid::Bsi.parse("BS 185 Index:1964")
      expect(id.to_s).to eq("BS 185 Index:1964")
    end

    it "renders BS 5000 Index Issue 4:1980 correctly" do
      id = Pubid::Bsi.parse("BS 5000 Index Issue 4:1980")
      expect(id.to_s).to eq("BS 5000 Index Issue 4:1980")
    end

    it "maintains round-trip fidelity" do
      original = "BS 5000 Index Issue 4:1980"
      id = Pubid::Bsi.parse(original)
      expect(id.to_s).to eq(original)
    end
  end
end
