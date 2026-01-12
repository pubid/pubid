# frozen_string_literal: true

require "spec_helper"

RSpec.describe "NIST Multi-Format Rendering" do
  describe "short format" do
    it "renders basic identifier in short format" do
      identifier = PubidNew::Nist.parse("NIST SP 800-53")
      expect(identifier.to_s(:short)).to eq("NIST SP 800-53")
    end

    it "renders identifier with edition in short format" do
      identifier = PubidNew::Nist.parse("NIST SP 800-53 r5")
      expect(identifier.to_s(:short)).to eq("NIST SP 800-53 r5")
    end

    it "renders identifier with stage in short format" do
      identifier = PubidNew::Nist.parse("NIST SP 800-53 ipd")
      expect(identifier.to_s(:short)).to eq("NIST SP 800-53 ipd")
    end

    it "renders identifier with translation in short format" do
      identifier = PubidNew::Nist.parse("NIST IR 8115 chi")
      expect(identifier.to_s(:short)).to include("zho")
    end

    it "renders NBS identifier in short format" do
      identifier = PubidNew::Nist.parse("NBS CIRC 11e1911")
      expect(identifier.to_s(:short)).to eq("NBS CIRC 11e1911")
    end
  end

  describe "mr (machine-readable) format" do
    it "renders basic identifier in mr format" do
      identifier = PubidNew::Nist.parse("NIST SP 800-53")
      expect(identifier.to_s(:mr)).to eq("NIST.SP.800-53")
    end

    it "renders identifier with edition in mr format" do
      identifier = PubidNew::Nist.parse("NIST SP 800-53 r5")
      expect(identifier.to_s(:mr)).to eq("NIST.SP.800-53 r5")
    end

    it "renders identifier with stage in mr format" do
      identifier = PubidNew::Nist.parse("NIST SP 800-53 ipd")
      expect(identifier.to_s(:mr)).to eq("NIST.SP.800-53.ipd")
    end

    it "renders identifier with translation in mr format" do
      identifier = PubidNew::Nist.parse("NIST IR 8115 chi")
      expect(identifier.to_s(:mr)).to include(".zho")
    end
  end

  describe "full (long) format" do
    it "renders basic identifier in full format" do
      identifier = PubidNew::Nist.parse("NIST SP 800-53")
      expect(identifier.to_s(:full)).to eq("National Institute of Standards and Technology SP 800-53")
    end

    it "renders identifier with edition in full format" do
      identifier = PubidNew::Nist.parse("NIST SP 800-53 r5")
      expect(identifier.to_s(:full)).to include("Revision 5")
    end

    it "renders identifier with stage in full format" do
      identifier = PubidNew::Nist.parse("NIST SP 800-53 ipd")
      expect(identifier.to_s(:full)).to include("(Initial Public Draft)")
    end

    it "renders identifier with translation in full format" do
      identifier = PubidNew::Nist.parse("NIST IR 8115 chi")
      expect(identifier.to_s(:full)).to include(" zho")
    end
  end

  describe "abbreviated format" do
    it "renders basic identifier in abbreviated format" do
      identifier = PubidNew::Nist.parse("NIST SP 800-53")
      result = identifier.to_s(:abbrev)
      expect(result).to include("Natl.")
      expect(result).to include("Spec. Publ.")
      expect(result).to include("800-53")
    end

    it "renders identifier with edition in abbreviated format" do
      identifier = PubidNew::Nist.parse("NIST SP 800-53 r5")
      result = identifier.to_s(:abbrev)
      expect(result).to include("r5")
    end

    it "renders identifier with stage in abbreviated format" do
      identifier = PubidNew::Nist.parse("NIST SP 800-53 ipd")
      result = identifier.to_s(:abbrev)
      expect(result).to include("ipd")
    end
  end

  describe "NBS historical identifiers" do
    it "renders NBS identifier in short format" do
      identifier = PubidNew::Nist.parse("NBS CIRC 11e1911")
      expect(identifier.to_s(:short)).to eq("NBS CIRC 11e1911")
    end

    it "renders NBS identifier in mr format" do
      identifier = PubidNew::Nist.parse("NBS CIRC 11e1911")
      expect(identifier.to_s(:mr)).to eq("NBS.CIRC.11e1911")
    end

    it "renders NBS identifier in full format" do
      identifier = PubidNew::Nist.parse("NBS CIRC 11e1911")
      result = identifier.to_s(:full)
      expect(result).to include("National Bureau of Standards")
      expect(result).to include("CIRC")
    end
  end

  describe "complex identifiers with multiple components" do
    it "renders identifier with edition and stage in short format" do
      identifier = PubidNew::Nist.parse("NIST SP 800-53e5 ipd")
      result = identifier.to_s(:short)
      expect(result).to include("800-53")
      expect(result).to include("e5")
      expect(result).to include("ipd")
    end

    it "renders identifier with edition and stage in mr format" do
      identifier = PubidNew::Nist.parse("NIST SP 800-53e5 ipd")
      result = identifier.to_s(:mr)
      expect(result).to include("800-53")
      expect(result).to include("e5")
      expect(result).to include(".ipd")
    end
  end

  describe "format aliases" do
    it "treats :long as alias for :full" do
      identifier = PubidNew::Nist.parse("NIST SP 800-53")
      expect(identifier.to_s(:long)).to eq(identifier.to_s(:full))
    end

    it "treats :abbrev as alias for :abbreviated" do
      identifier = PubidNew::Nist.parse("NIST SP 800-53")
      expect(identifier.to_s(:abbrev)).to eq(identifier.to_s(:abbreviated))
    end
  end

  describe "default format" do
    it "uses short format when no format specified" do
      identifier = PubidNew::Nist.parse("NIST SP 800-53")
      expect(identifier.to_s).to eq("NIST SP 800-53")
    end
  end
end
