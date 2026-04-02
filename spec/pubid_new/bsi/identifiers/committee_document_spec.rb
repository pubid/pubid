# frozen_string_literal: true

require_relative "../../../../lib/pubid_new/bsi"

RSpec.describe PubidNew::Bsi::Identifiers::CommitteeDocument do
  describe "parsing" do
    it "parses 14/30300822 DC" do
      id = PubidNew::Bsi.parse("14/30300822 DC")
      expect(id.class).to eq(PubidNew::Bsi::Identifiers::CommitteeDocument)
    end

    it "parses 21/30445138 DC" do
      id = PubidNew::Bsi.parse("21/30445138 DC")
      expect(id.class).to eq(PubidNew::Bsi::Identifiers::CommitteeDocument)
    end

    it "parses 24/30488529 DC" do
      id = PubidNew::Bsi.parse("24/30488529 DC")
      expect(id.class).to eq(PubidNew::Bsi::Identifiers::CommitteeDocument)
    end
  end

  describe "rendering" do
    it "renders 14/30300822 DC correctly" do
      id = PubidNew::Bsi.parse("14/30300822 DC")
      expect(id.to_s).to eq("14/30300822 DC")
    end

    it "renders 21/30445138 DC correctly" do
      id = PubidNew::Bsi.parse("21/30445138 DC")
      expect(id.to_s).to eq("21/30445138 DC")
    end

    it "maintains round-trip fidelity" do
      original = "21/30445138 DC"
      id = PubidNew::Bsi.parse(original)
      expect(id.to_s).to eq(original)
    end
  end
end
