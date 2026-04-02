# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Nist::Components::Edition do
  describe "initialization and basic attributes" do
    context "with edition number only" do
      it "creates edition with number" do
        edition = described_class.new(type: "e", id: "2")
        expect(edition.type).to eq("e")
        expect(edition.id).to eq("2")
        expect(edition.additional_text).to be_nil
      end

      it "creates revision edition with number" do
        edition = described_class.new(type: "r", id: "5")
        expect(edition.type).to eq("r")
        expect(edition.id).to eq("5")
        expect(edition.additional_text).to be_nil
      end

      it "creates historical edition" do
        edition = described_class.new(type: "-", id: "3")
        expect(edition.type).to eq("-")
        expect(edition.id).to eq("3")
      end
    end

    context "with year as edition ID" do
      it "creates edition with year" do
        edition = described_class.new(type: "e", id: "2021")
        expect(edition.type).to eq("e")
        expect(edition.id).to eq("2021")
      end

      it "creates revision with year" do
        edition = described_class.new(type: "r", id: "1963")
        expect(edition.type).to eq("r")
        expect(edition.id).to eq("1963")
      end
    end

    context "with additional text" do
      it "creates edition with month and year" do
        edition = described_class.new(type: "e", id: "2",
                                      additional_text: "June1908")
        expect(edition.type).to eq("e")
        expect(edition.id).to eq("2")
        expect(edition.additional_text).to eq("June1908")
      end

      it "creates edition with year only additional text" do
        edition = described_class.new(type: "e", id: "2",
                                      additional_text: "1908")
        expect(edition.type).to eq("e")
        expect(edition.id).to eq("2")
        expect(edition.additional_text).to eq("1908")
      end

      it "creates revision with additional text" do
        edition = described_class.new(type: "r", id: "5",
                                      additional_text: "March1920")
        expect(edition.type).to eq("r")
        expect(edition.id).to eq("5")
        expect(edition.additional_text).to eq("March1920")
      end
    end
  end

  describe "#to_s with short format (default)" do
    context "basic edition patterns" do
      it "renders edition number" do
        edition = described_class.new(type: "e", id: "2")
        expect(edition.to_s).to eq("e2")
      end

      it "renders revision number" do
        edition = described_class.new(type: "r", id: "5")
        expect(edition.to_s).to eq("r5")
      end

      it "renders historical edition" do
        edition = described_class.new(type: "-", id: "3")
        expect(edition.to_s).to eq("-3")
      end
    end

    context "edition with year as ID" do
      it "renders edition year" do
        edition = described_class.new(type: "e", id: "2021")
        expect(edition.to_s).to eq("e2021")
      end

      it "renders revision year" do
        edition = described_class.new(type: "r", id: "1963")
        expect(edition.to_s).to eq("r1963")
      end
    end

    context "edition with additional text" do
      it "renders edition with month and year using DOT separator" do
        edition = described_class.new(type: "e", id: "2",
                                      additional_text: "June1908")
        expect(edition.to_s).to eq("e2.June1908")
      end

      it "renders edition with year only using DOT separator" do
        edition = described_class.new(type: "e", id: "2",
                                      additional_text: "1908")
        expect(edition.to_s).to eq("e2.1908")
      end

      it "renders revision with additional text using DOT separator" do
        edition = described_class.new(type: "r", id: "5",
                                      additional_text: "March1920")
        expect(edition.to_s).to eq("r5.March1920")
      end

      it "never includes 'rev' in output" do
        edition = described_class.new(type: "e", id: "2",
                                      additional_text: "June1908")
        expect(edition.to_s).not_to include("rev")
        expect(edition.to_s).to include(".")
      end
    end
  end

  describe "#to_s with :mr format" do
    it "renders edition number in mr format" do
      edition = described_class.new(type: "e", id: "2")
      expect(edition.to_s(:mr)).to eq("e2")
    end

    it "renders edition with additional text in mr format" do
      edition = described_class.new(type: "e", id: "2",
                                    additional_text: "June1908")
      expect(edition.to_s(:mr)).to eq("e2.June1908")
    end

    it "renders revision in mr format" do
      edition = described_class.new(type: "r", id: "5")
      expect(edition.to_s(:mr)).to eq("r5")
    end
  end

  describe "#to_s with :long format" do
    it "renders edition number in long format" do
      edition = described_class.new(type: "e", id: "2")
      expect(edition.to_s(:long)).to eq("Edition 2")
    end

    it "renders edition year in long format" do
      edition = described_class.new(type: "e", id: "2021")
      expect(edition.to_s(:long)).to eq("Edition 2021")
    end

    it "renders revision number in long format" do
      edition = described_class.new(type: "r", id: "5")
      expect(edition.to_s(:long)).to eq("Revision 5")
    end

    it "renders revision year in long format" do
      edition = described_class.new(type: "r", id: "1963")
      expect(edition.to_s(:long)).to eq("Revision 1963")
    end

    it "renders historical edition in long format" do
      edition = described_class.new(type: "-", id: "3")
      expect(edition.to_s(:long)).to eq("-3")
    end

    context "with additional text" do
      it "renders edition with additional text" do
        edition = described_class.new(type: "e", id: "2",
                                      additional_text: "June1908")
        # Long format doesn't change additional text handling
        expect(edition.to_s(:long)).to eq("Edition 2")
      end
    end
  end

  describe "#to_s with :abbrev format" do
    it "renders edition number in abbreviated format" do
      edition = described_class.new(type: "e", id: "2")
      expect(edition.to_s(:abbrev)).to eq("e2")
    end

    it "renders edition with additional text in abbreviated format" do
      edition = described_class.new(type: "e", id: "2", additional_text: "1908")
      expect(edition.to_s(:abbrev)).to eq("e2.1908")
    end

    it "renders revision in abbreviated format" do
      edition = described_class.new(type: "r", id: "5")
      expect(edition.to_s(:abbrev)).to eq("r5")
    end
  end

  describe "integration with parsing" do
    context "parsing identifiers with edition" do
      it "parses e2 pattern" do
        id = Pubid::Nist.parse("NIST SP 800-53e2")
        expect(id.edition).to be_a(described_class)
        expect(id.edition.type).to eq("e")
        expect(id.edition.id).to eq("2")
        expect(id.edition.to_s).to eq("e2")
      end

      it "parses r5 pattern" do
        id = Pubid::Nist.parse("NIST SP 800-53r5")
        expect(id.edition).to be_a(described_class)
        expect(id.edition.type).to eq("r")
        expect(id.edition.id).to eq("5")
        expect(id.edition.to_s).to eq("r5")
      end

      it "parses r1963 pattern (revision as year)" do
        id = Pubid::Nist.parse("NBS LCIRC 1019r1963")
        expect(id.edition).to be_a(described_class)
        expect(id.edition.type).to eq("r")
        expect(id.edition.id).to eq("1963")
        expect(id.edition.to_s).to eq("r1963")
      end

      it "parses e2revJune1908 pattern (legacy format with rev)" do
        id = Pubid::Nist.parse("NBS CIRC 13e2revJune1908")
        expect(id.edition).to be_a(described_class)
        expect(id.edition.type).to eq("e")
        expect(id.edition.id).to eq("2")
        expect(id.edition.additional_text).to eq("June1908")
        # Canonical rendering uses DOT, not "rev"
        expect(id.edition.to_s).to eq("e2.June1908")
      end

      it "parses e2rev1908 pattern (legacy format with rev and year)" do
        id = Pubid::Nist.parse("NBS CIRC 13e2rev1908")
        expect(id.edition).to be_a(described_class)
        expect(id.edition.type).to eq("e")
        expect(id.edition.id).to eq("2")
        expect(id.edition.additional_text).to eq("1908")
        # Canonical rendering uses DOT
        expect(id.edition.to_s).to eq("e2.1908")
      end
    end
  end

  describe "round-trip fidelity" do
    it "maintains dotted notation for edition with additional text" do
      original_input = "NBS CIRC 13e2revJune1908"
      canonical_output = "NBS CIRC 13e2.June1908"

      parsed = Pubid::Nist.parse(original_input)
      expect(parsed.to_s).to eq(canonical_output)
    end

    it "renders simple edition correctly" do
      id = Pubid::Nist.parse("NIST SP 800-53r5")
      expect(id.to_s).to eq("NIST SP 800-53r5")
    end

    it "renders revision year correctly" do
      id = Pubid::Nist.parse("NBS LCIRC 1019r1963")
      expect(id.to_s).to eq("NBS LC 1019r1963")
    end
  end

  describe "edge cases" do
    it "handles empty additional text" do
      edition = described_class.new(type: "e", id: "2", additional_text: "")
      expect(edition.to_s).to eq("e2")
    end

    it "handles nil additional text" do
      edition = described_class.new(type: "e", id: "2", additional_text: nil)
      expect(edition.to_s).to eq("e2")
    end

    it "handles different month formats in additional text" do
      [
        { month: "Jan", expected: "e2.Jan1908" },
        { month: "February", expected: "e2.February1908" },
        { month: "Mar", expected: "e2.Mar1908" },
      ].each do |test_case|
        edition = described_class.new(type: "e", id: "2",
                                      additional_text: "#{test_case[:month]}1908")
        expect(edition.to_s).to eq(test_case[:expected])
      end
    end
  end
end
