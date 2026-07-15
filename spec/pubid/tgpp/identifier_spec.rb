# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Tgpp::Identifier do
  describe ".parse" do
    context "technical specification with REL- release" do
      subject { "TS 23.207:REL-4/2.0.0" }

      let(:parsed) { described_class.parse(subject) }

      it "parses as TechnicalSpecification" do
        expect(parsed).to be_a(Pubid::Tgpp::Identifiers::TechnicalSpecification)
      end

      it "parses the dotted number core" do
        expect(parsed.number).to eq("23.207")
      end

      it "has no suffix" do
        expect(parsed.suffix).to be_nil
      end

      it "has no parts" do
        expect(parsed.parts).to eq([])
      end

      it "parses the release verbatim" do
        expect(parsed.release).to eq("REL-4")
      end

      it "parses the version" do
        expect(parsed.version).to eq("2.0.0")
      end

      it "round-trips without publisher by default" do
        expect(parsed.to_s).to eq(subject)
      end

      it "renders with the 3GPP publisher on request" do
        expect(parsed.to_s(with_publisher: true))
          .to eq("3GPP TS 23.207:REL-4/2.0.0")
      end

      it "does not leak the publisher flag past the to_s call that set it" do
        parsed.to_s(with_publisher: true)
        expect(parsed.render(format: :human)).to eq("TS 23.207:REL-4/2.0.0")
      end
    end

    context "technical report" do
      subject { "TR 26.905:REL-8/1.0.0" }

      let(:parsed) { described_class.parse(subject) }

      it "parses as TechnicalReport" do
        expect(parsed).to be_a(Pubid::Tgpp::Identifiers::TechnicalReport)
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    context "accepts an optional leading 3GPP prefix on input" do
      subject { "3GPP TS 23.207:REL-4/2.0.0" }

      let(:parsed) { described_class.parse(subject) }

      it "normalizes to the no-prefix form" do
        expect(parsed.to_s).to eq("TS 23.207:REL-4/2.0.0")
      end
    end

    context "letter suffix on the number (U / dcs / ext)" do
      describe "UMTS 'U' suffix" do
        subject { "TR 00.01U:UMTS/3.0.0" }

        let(:parsed) { described_class.parse(subject) }

        it "captures the suffix" do
          expect(parsed.suffix).to eq("U")
        end

        it "parses the UMTS release" do
          expect(parsed.release).to eq("UMTS")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "'dcs' suffix with Ph release" do
        subject { "TS 02.06dcs:Ph1/2.0.0" }

        let(:parsed) { described_class.parse(subject) }

        it "captures the suffix" do
          expect(parsed.suffix).to eq("dcs")
        end

        it "parses the phase release" do
          expect(parsed.release).to eq("Ph1")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "hyphenated parts" do
      describe "single part" do
        subject { "TS 26.171-1:REL-8/8.0.0" }

        let(:parsed) { described_class.parse(subject) }

        it "parses the part" do
          expect(parsed.parts).to eq(["1"])
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "two-level, zero-padded parts" do
        subject { "TS 29.198-04-1:REL-5/5.0.0" }

        let(:parsed) { described_class.parse(subject) }

        it "preserves both zero-padded parts" do
          expect(parsed.parts).to eq(%w[04 1])
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "'Release N' release form (with internal space)" do
      subject { "TS 02.68:Release 2000/9.0.0" }

      let(:parsed) { described_class.parse(subject) }

      it "parses the whole release token verbatim" do
        expect(parsed.release).to eq("Release 2000")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    context "legacy record with no release segment" do
      subject { "TS 29.215/2.0.0" }

      let(:parsed) { described_class.parse(subject) }

      it "has a nil release" do
        expect(parsed.release).to be_nil
      end

      it "still parses the version" do
        expect(parsed.version).to eq("2.0.0")
      end

      it "round-trips without a release colon" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    context "input length guard" do
      it "raises ArgumentError for over-long input" do
        expect { described_class.parse("TS #{'9' * 1001}") }
          .to raise_error(ArgumentError, /maximum length/)
      end
    end
  end
end
