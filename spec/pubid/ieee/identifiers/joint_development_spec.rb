# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Ieee::Identifiers::JointDevelopment do
  subject { described_class }

  describe "Lead Party Architecture" do
    context "IEEE-led format (P prefix)" do
      describe "ISO/IEC/IEEE P26511/D8-2018" do
        subject { "ISO/IEC/IEEE P26511/D8-2018" }
        let(:parsed) { Pubid::Ieee.parse(subject) }

        it "parses as JointDevelopment" do
          expect(parsed).to be_a(described_class)
        end

        it "detects IEEE as lead party" do
          expect(parsed.lead_party).to eq("IEEE")
        end

        it "sets publishers correctly" do
          expect(parsed.publishers).to eq(["ISO", "IEC", "IEEE"])
        end

        it "sets canonical format to IEEE" do
          expect(parsed.canonical_format).to eq(:ieee)
        end

        it "round-trips in IEEE format" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "ISO-led format (stage codes)" do
      describe "ISO/IEC/IEEE FDIS 26511:2018" do
        subject { "ISO/IEC/IEEE FDIS 26511:2018" }
        let(:parsed) { Pubid::Ieee.parse(subject) }

        it "parses as JointDevelopment" do
          expect(parsed).to be_a(described_class)
        end

        it "detects ISO as lead party" do
          expect(parsed.lead_party).to eq("ISO")
        end

        it "sets publishers correctly" do
          expect(parsed.publishers).to eq(["ISO", "IEC", "IEEE"])
        end

        it "sets canonical format to ISO" do
          expect(parsed.canonical_format).to eq(:iso)
        end

        it "round-trips in ISO format" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "ISO/IEC/IEEE DIS 16326:2008" do
        subject { "ISO/IEC/IEEE DIS 16326:2008" }
        let(:parsed) { Pubid::Ieee.parse(subject) }

        it "parses as JointDevelopment" do
          expect(parsed).to be_a(described_class)
        end

        it "detects ISO as lead party" do
          expect(parsed.lead_party).to eq("ISO")
        end

        it "sets ISO stage" do
          expect(parsed.iso_stage).to eq("DIS")
        end
      end
    end

    context "Dual format conversion" do
      it "IEEE format can be converted to ISO format" do
        ieee_id = Pubid::Ieee.parse("ISO/IEC/IEEE P26511/D3-2018")
        iso_format = ieee_id.to_s(format: :iso)

        expect(iso_format).to include("ISO/IEC/IEEE")
        expect(iso_format).to include("26511")
        expect(iso_format).to include(":2018")
        expect(iso_format).not_to include("P")
      end

      it "ISO format can be converted to IEEE format" do
        iso_id = Pubid::Ieee.parse("ISO/IEC/IEEE FDIS 26511:2018")
        ieee_format = iso_id.to_s(format: :ieee)

        expect(ieee_format).to include("ISO/IEC/IEEE")
        expect(ieee_format).to include("P26511")
        expect(ieee_format).to include("-2018")
      end
    end

    context "Lead party determines canonical format" do
      it "IEEE-led uses IEEE format by default" do
        ieee_led = Pubid::Ieee.parse("ISO/IEC/IEEE P26511/D8-2018")
        expect(ieee_led.to_s).to include("P26511")
      end

      it "ISO-led uses ISO format by default" do
        iso_led = Pubid::Ieee.parse("ISO/IEC/IEEE FDIS 26511:2018")
        expect(iso_led.to_s).to include("FDIS")
        expect(iso_led.to_s).not_to include("P")
      end
    end
  end

  describe "Architectural Principles" do
    it "maintains NO equivalence between IEEE and ISO stages" do
      # As per IEEE staff guidance: CD ≠ Unapproved Draft
      # They can coexist but are not equivalent

      ieee_id = Pubid::Ieee.parse("ISO/IEC/IEEE P26511/D3-2018")
      iso_id = Pubid::Ieee.parse("ISO/IEC/IEEE CD 26511:2018")

      # Different identifiers, different stages, NO automatic mapping
      expect(ieee_id.typed_stage).not_to eq(iso_id.typed_stage) if ieee_id.typed_stage && iso_id.typed_stage
    end

    it "preserves semantic meaning within each system" do
      ieee_id = Pubid::Ieee.parse("ISO/IEC/IEEE P26511/D8-2018")

      # IEEE format preserves P (project) and D8 (draft 8)
      expect(ieee_id.to_s(format: :ieee)).to include("P26511")
      expect(ieee_id.to_s(format: :ieee)).to include("/D8")

      # ISO format removes IEEE-specific notation
      iso_format = ieee_id.to_s(format: :iso)
      expect(iso_format).not_to include("/D")
    end
  end

  describe "Edge cases" do
    context "ISO/IEEE (without IEC)" do
      describe "ISO/IEEE P1003.1-2008" do
        subject { "ISO/IEEE P1003.1-2008" }
        let(:parsed) { Pubid::Ieee.parse(subject) }

        it "parses correctly" do
          expect(parsed).to be_a(described_class)
          expect(parsed.publishers).to eq(["ISO", "IEEE"])
        end
      end
    end

    context "IEC/IEEE (without ISO)" do
      describe "IEC/IEEE P62582-1-2011" do
        subject { "IEC/IEEE P62582-1-2011" }
        let(:parsed) { Pubid::Ieee.parse(subject) }

        it "parses correctly" do
          expect(parsed).to be_a(described_class)
          expect(parsed.publishers).to eq(["IEC", "IEEE"])
        end
      end
    end
  end
end
