# frozen_string_literal: true

require "pubid/iso/utilities"

RSpec.describe Pubid::Iso::Utilities do
  describe ".parse_from_title" do
    context "with title starting with identifier" do
      it "extracts ISO identifier with year" do
        title = "ISO 9001:2015 Quality management systems"
        id = described_class.parse_from_title(title)
        expect(id.to_s).to eq("ISO 9001:2015")
      end

      it "extracts ISO/IEC identifier with part and year" do
        title = "ISO/IEC 8601-1:2019 Date and time"
        id = described_class.parse_from_title(title)
        expect(id.to_s).to eq("ISO/IEC 8601-1:2019")
      end

      it "extracts ISO identifier without year" do
        title = "ISO 27001 Information security"
        id = described_class.parse_from_title(title)
        expect(id.to_s).to eq("ISO 27001")
      end

      it "extracts IEC identifier" do
        title = "IEC 60050 International Electrotechnical Vocabulary"
        id = described_class.parse_from_title(title)
        expect(id.to_s).to eq("IEC 60050")
      end
    end

    context "with identifier in middle of title" do
      it "finds ISO identifier within title" do
        title = "Quality management systems - ISO 9001:2015 requirements"
        id = described_class.parse_from_title(title)
        expect(id.to_s).to eq("ISO 9001:2015")
      end

      it "finds ISO/IEC identifier within title" do
        title = "Document on ISO/IEC 27001:2013 security controls"
        id = described_class.parse_from_title(title)
        expect(id.to_s).to eq("ISO/IEC 27001:2013")
      end
    end

    context "with title using em-dash separator" do
      it "extracts identifier from em-dash separated title" do
        title = "Information technology — ISO 19110 — Geographic information"
        id = described_class.parse_from_title(title)
        expect(id.to_s).to eq("ISO 19110")
      end

      it "extracts identifier from complex title" do
        title = "Geographic information — ISO 19110:2005 — Feature cataloguing"
        id = described_class.parse_from_title(title)
        expect(id.to_s).to eq("ISO 19110:2005")
      end
    end

    context "with multiple potential identifiers" do
      it "extracts first valid identifier" do
        title = "Reference to ISO 9001 and ISO 14001 in quality management"
        id = described_class.parse_from_title(title)
        # Should find one of the identifiers
        expect(id.to_s).to match(/ISO (9001|14001)/)
      end
    end

    context "with no valid identifier" do
      it "returns nil for title without identifier" do
        title = "Quality Management Systems Handbook"
        expect(described_class.parse_from_title(title)).to be_nil
      end

      it "returns nil for empty title" do
        expect(described_class.parse_from_title("")).to be_nil
      end

      it "returns nil for nil title" do
        expect(described_class.parse_from_title(nil)).to be_nil
      end
    end

    context "with supplement identifiers in title" do
      it "extracts amendment from title" do
        title = "ISO 9001:2015/Amd 1:2016 modified"
        id = described_class.parse_from_title(title)
        expect(id.to_s).to eq("ISO 9001:2015/Amd 1:2016")
      end

      it "extracts corrigendum from title" do
        title = "ISO 2631-1:1997/Cor 1:1999 details"
        id = described_class.parse_from_title(title)
        expect(id.to_s).to eq("ISO 2631-1:1997/Cor 1:1999")
      end
    end
  end
end
