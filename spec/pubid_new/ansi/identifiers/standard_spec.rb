# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Ansi::Identifiers::Standard do
  # ========================================
  # Standard (76 IDs, 26%)
  # ========================================
  context "Standard identifiers" do
    let(:parsed) { PubidNew::Ansi.parse(subject) }

    it "parses letter-less simple standard" do
      subject { "ANSI 802.3-2012" }
      expect(result).to be_a(described_class)
      expect(result.code.letter).to be_nil
      expect(result.code.number).to eq("802.3")
      expect(result.year).to eq("2012")
      expect(result.to_s).to eq(subject)
    end

    # ANSI C135.14-1979

    it "parses lettered standard with dash year" do
      subject { "ANSI C135.14-1979" }
      expect(result).to be_a(described_class)
      expect(result.code.letter).to eq("C")
      expect(result.code.number).to eq("135.14")
      expect(result.year).to eq("1979")
      expect(result.to_s).to eq(subject)
    end


    # ANSI C37.06.1-2000
    it "parses lettered standard with complex number and dash year" do
      subject { "ANSI C37.06.1-2000" }
      expect(result).to be_a(described_class)
      expect(result.code.letter).to eq("C")
      expect(result.code.number).to eq("37.06.1")
      expect(result.year).to eq("2000")
      expect(result.to_s).to eq(subject)
    end

    # ANSI N323D-2002
    it "parses lettered standard with letter suffix and dash year" do
      subject { "ANSI N323D-2002" }
      expect(result).to be_a(described_class)
      expect(result.code.letter).to eq("N")
      expect(result.code.number).to eq("323D")
      expect(result.year).to eq("2002")
      expect(result.to_s).to eq(subject)
    end

  end

  context "Co-published identifiers" do
    let(:parsed) { PubidNew::Ansi.parse(subject) }

    # ANSI/ASME B16.5
    it "parses co-published standard with slash" do
      subject { "ANSI/ASME B16.5" }
      expect(result).to be_a(described_class)
      expect(result.code.letter).to eq("B")
      expect(result.code.number).to eq("16.5")
      expect(result.year).to be_nil
      expect(result.copublishers.first.body).to eq("ASME")
    end

    # ANSI/ASTM E1527
    it "parses co-published standard with slash and dash year" do
      subject { "ANSI/ASTM E1527-2013" }
      expect(result).to be_a(described_class)
      expect(result.code.letter).to eq("E")
      expect(result.code.number).to eq("1527")
      expect(result.year).to eq("2013")
      expect(result.copublishers.first.body).to eq("ASTM")
    end

    # ANSI/IEC 60601-1
    it "parses co-published standard with IEC" do
      subject { "ANSI/IEC 60601-1" }
      expect(result).to be_a(described_class)
      expect(result.code.letter).to be_nil
      expect(result.code.number).to eq("60601-1")
      expect(result.year).to be_nil
      expect(result.copublishers.first.body).to eq("IEC")
    end

    # ANSI/IEEE 1-1986
    it "parses co-published standard with IEEE" do
      subject { "ANSI/IEEE 1-1986" }
      expect(result).to be_a(described_class)
      expect(result.code.letter).to be_nil
      expect(result.code.number).to eq("1")
      expect(result.year).to eq("1986")
      expect(result.copublishers.first.body).to eq("IEEE")
    end

    # ANSI/IEEE 802.3j-1993
    it "parses co-published standard with IEEE and complex number" do
      subject { "ANSI/IEEE 802.3j-1993" }
      expect(result).to be_a(described_class)
      expect(result.code.letter).to be_nil
      expect(result.code.number).to eq("802.3j")
      expect(result.year).to eq("1993")
      expect(result.copublishers.first.body).to eq("IEEE")
    end

    # ANSI/IEEE C67.92-1987
    it "parses co-published standard with IEEE and lettered complex number" do
      subject { "ANSI/IEEE C67.92-1987" }
      expect(result).to be_a(described_class)
      expect(result.code.letter).to eq("C")
      expect(result.code.number).to eq("67.92")
      expect(result.year).to eq("1987")
      expect(result.copublishers.first.body).to eq("IEEE")
    end

    # ANSI/ISO 9899:1990
    it "parses co-published standard with ISO and colon year" do
      subject { "ANSI/ISO 9899:1990" }
      expect(result).to be_a(described_class)
      expect(result.code.letter).to be_nil
      expect(result.code.number).to eq("9899")
      expect(result.year).to eq("1990")
      expect(result.copublishers.first.body).to eq("ISO")
      expect(result.to_s).to eq(subject)
    end

    # ANSI/SAE J1939
    it "parses co-published standard with SAE and no year" do
      subject { "ANSI/SAE J1939" }
      expect(result).to be_a(described_class)
      expect(result.code.letter).to eq("J")
      expect(result.code.number).to eq("1939")
      expect(result.year).to be_nil
      expect(result.copublishers.first.body).to eq("SAE")
    end
  end
end
