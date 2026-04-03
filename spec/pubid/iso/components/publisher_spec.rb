require "spec_helper"

RSpec.describe Pubid::Iso::Components::Publisher do
  describe "#initialize" do
    it "accepts publisher parameter" do
      publisher = described_class.new(publisher: "ISO")
      expect(publisher.publisher).to eq("ISO")
    end

    it "accepts copublisher array" do
      publisher = described_class.new(publisher: "ISO",
                                      copublisher: [
                                        "IEC", "IEEE"
                                      ])
      expect(publisher.copublisher).to eq(["IEC", "IEEE"])
    end

    it "accepts nil copublisher" do
      publisher = described_class.new(publisher: "ISO", copublisher: nil)
      expect(publisher.copublisher).to be_nil
    end
  end

  describe "#to_s" do
    it "renders single publisher" do
      publisher = described_class.new(publisher: "ISO")
      expect(publisher.to_s).to eq("ISO")
    end

    it "renders with single copublisher" do
      publisher = described_class.new(publisher: "ISO", copublisher: ["IEC"])
      expect(publisher.to_s).to eq("ISO/IEC")
    end

    it "renders with multiple copublishers" do
      publisher = described_class.new(publisher: "ISO",
                                      copublisher: [
                                        "IEC", "IEEE"
                                      ])
      expect(publisher.to_s).to eq("ISO/IEC/IEEE")
    end

    it "renders with three copublishers" do
      publisher = described_class.new(publisher: "ISO",
                                      copublisher: [
                                        "IEC", "IEEE", "SAE"
                                      ])
      expect(publisher.to_s).to eq("ISO/IEC/IEEE/SAE")
    end

    it "handles nil copublisher" do
      publisher = described_class.new(publisher: "ISO", copublisher: nil)
      expect(publisher.to_s).to eq("ISO")
    end

    it "handles empty copublisher array" do
      publisher = described_class.new(publisher: "ISO", copublisher: [])
      expect(publisher.to_s).to eq("ISO")
    end
  end

  describe "#has_copublisher?" do
    it "returns falsy when no copublisher" do
      publisher = described_class.new(publisher: "ISO")
      expect(publisher.has_copublisher?).to be_falsy
    end

    it "returns falsy when copublisher is nil" do
      publisher = described_class.new(publisher: "ISO", copublisher: nil)
      expect(publisher.has_copublisher?).to be_falsy
    end

    it "returns false when copublisher is empty array" do
      publisher = described_class.new(publisher: "ISO", copublisher: [])
      expect(publisher.has_copublisher?).to be false
    end

    it "returns true when copublisher present" do
      publisher = described_class.new(publisher: "ISO", copublisher: ["IEC"])
      expect(publisher.has_copublisher?).to be true
    end

    it "returns true when multiple copublishers present" do
      publisher = described_class.new(publisher: "ISO",
                                      copublisher: [
                                        "IEC", "IEEE"
                                      ])
      expect(publisher.has_copublisher?).to be true
    end
  end

  describe "#==" do
    it "treats same publisher and copublishers as equal" do
      pub1 = described_class.new(publisher: "ISO", copublisher: ["IEC"])
      pub2 = described_class.new(publisher: "ISO", copublisher: ["IEC"])
      expect(pub1).to eq(pub2)
    end

    it "treats different publishers as not equal" do
      pub1 = described_class.new(publisher: "ISO")
      pub2 = described_class.new(publisher: "IEC")
      expect(pub1).not_to eq(pub2)
    end

    it "treats different copublishers as not equal" do
      pub1 = described_class.new(publisher: "ISO", copublisher: ["IEC"])
      pub2 = described_class.new(publisher: "ISO", copublisher: ["IEEE"])
      expect(pub1).not_to eq(pub2)
    end
  end
end
