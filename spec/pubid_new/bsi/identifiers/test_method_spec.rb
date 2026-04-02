# frozen_string_literal: true

require_relative "../../../../lib/pubid_new/bsi"

RSpec.describe PubidNew::Bsi::Identifiers::TestMethod do
  describe "parsing" do
    it "parses BS 1006:B01C:LFS1:1982" do
      id = PubidNew::Bsi.parse("BS 1006:B01C:LFS1:1982")
      expect(id.class).to eq(PubidNew::Bsi::Identifiers::TestMethod)
    end

    it "parses BS 1006:B01C:LFS2:1985" do
      id = PubidNew::Bsi.parse("BS 1006:B01C:LFS2:1985")
      expect(id.class).to eq(PubidNew::Bsi::Identifiers::TestMethod)
    end

    it "parses BS 1006:B01C:LFS4:1990" do
      id = PubidNew::Bsi.parse("BS 1006:B01C:LFS4:1990")
      expect(id.class).to eq(PubidNew::Bsi::Identifiers::TestMethod)
    end

    it "parses BS 1006:B01C:LFS5:1988" do
      id = PubidNew::Bsi.parse("BS 1006:B01C:LFS5:1988")
      expect(id.class).to eq(PubidNew::Bsi::Identifiers::TestMethod)
    end

    it "parses BS 1006:B01C:LFS7:1985" do
      id = PubidNew::Bsi.parse("BS 1006:B01C:LFS7:1985")
      expect(id.class).to eq(PubidNew::Bsi::Identifiers::TestMethod)
    end

    it "parses BS 1006:B01C:LFS8:1987" do
      id = PubidNew::Bsi.parse("BS 1006:B01C:LFS8:1987")
      expect(id.class).to eq(PubidNew::Bsi::Identifiers::TestMethod)
    end
  end

  describe "rendering" do
    it "renders BS 1006:B01C:LFS1:1982 correctly" do
      id = PubidNew::Bsi.parse("BS 1006:B01C:LFS1:1982")
      expect(id.to_s).to eq("BS 1006:B01C:LFS1:1982")
    end

    it "renders BS 1006:B01C:LFS2:1985 correctly" do
      id = PubidNew::Bsi.parse("BS 1006:B01C:LFS2:1985")
      expect(id.to_s).to eq("BS 1006:B01C:LFS2:1985")
    end

    it "renders BS 1006:B01C:LFS4:1990 correctly" do
      id = PubidNew::Bsi.parse("BS 1006:B01C:LFS4:1990")
      expect(id.to_s).to eq("BS 1006:B01C:LFS4:1990")
    end

    it "maintains round-trip fidelity" do
      original = "BS 1006:B01C:LFS1:1982"
      id = PubidNew::Bsi.parse(original)
      expect(id.to_s).to eq(original)
    end
  end
end
