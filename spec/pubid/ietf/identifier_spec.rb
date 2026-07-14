# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Ietf::Identifier do
  describe ".parse" do
    context "RFC" do
      describe "RFC 2119" do
        subject { "RFC 2119" }

        let(:parsed) { described_class.parse(subject) }

        it "parses as Rfc" do
          expect(parsed).to be_a(Pubid::Ietf::Identifiers::Rfc)
        end

        it "parses the number as a string (no zero-pad)" do
          expect(parsed.number).to eq("2119")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      it "parses a single-digit RFC" do
        expect(described_class.parse("RFC 1").number).to eq("1")
      end
    end

    context "sub-series" do
      {
        "BCP 3" => [Pubid::Ietf::Identifiers::Bcp, "BCP"],
        "STD 66" => [Pubid::Ietf::Identifiers::Std, "STD"],
        "FYI 1" => [Pubid::Ietf::Identifiers::Fyi, "FYI"],
      }.each do |ref, (klass, series)|
        describe ref do
          let(:parsed) { described_class.parse(ref) }

          it "parses as #{klass}" do
            expect(parsed).to be_a(klass)
          end

          it "parses series and number" do
            expect(parsed.series).to eq(series)
            expect(parsed.number).to eq(ref.split.last)
          end

          it "round-trips" do
            expect(parsed.to_s).to eq(ref)
          end
        end
      end
    end

    context "Internet-Draft" do
      describe "draft-giuliano-treedn-02 (versioned)" do
        subject { "draft-giuliano-treedn-02" }

        let(:parsed) { described_class.parse(subject) }

        it "parses as InternetDraft" do
          expect(parsed).to be_a(Pubid::Ietf::Identifiers::InternetDraft)
        end

        it "keeps the leading draft- in name and splits the version" do
          expect(parsed.name).to eq("draft-giuliano-treedn")
          expect(parsed.version).to eq("02")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "draft-giuliano-treedn (unversioned)" do
        subject { "draft-giuliano-treedn" }

        let(:parsed) { described_class.parse(subject) }

        it "has a nil version" do
          expect(parsed.name).to eq("draft-giuliano-treedn")
          expect(parsed.version).to be_nil
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "draft-adams-cast-256 (three-digit topic tail, not a version)" do
        subject { "draft-adams-cast-256" }

        let(:parsed) { described_class.parse(subject) }

        it "keeps the digits in the name and has no version" do
          expect(parsed.name).to eq("draft-adams-cast-256")
          expect(parsed.version).to be_nil
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "draft-aboba-context-802-00 (digit-tail topic + version)" do
        subject { "draft-aboba-context-802-00" }

        let(:parsed) { described_class.parse(subject) }

        it "splits only the final two-digit version" do
          expect(parsed.name).to eq("draft-aboba-context-802")
          expect(parsed.version).to eq("00")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      it "handles a slug ending in four digits (no version)" do
        parsed = described_class.parse("draft-ietf-mpls-ldp-survey2002")
        expect(parsed.name).to eq("draft-ietf-mpls-ldp-survey2002")
        expect(parsed.version).to be_nil
        expect(parsed.to_s).to eq("draft-ietf-mpls-ldp-survey2002")
      end

      it "handles + and _ in the slug" do
        expect(described_class.parse("draft-durand-gse+-00").to_s)
          .to eq("draft-durand-gse+-00")
        expect(described_class.parse("draft-conta-ipv6-nd_ext_ind-00").to_s)
          .to eq("draft-conta-ipv6-nd_ext_ind-00")
      end
    end

    context "invalid input" do
      it "raises on an unrecognized token" do
        expect { described_class.parse("XYZ 1") }.to raise_error(StandardError)
      end

      it "raises on trailing garbage" do
        expect { described_class.parse("RFC 2119x") }
          .to raise_error(StandardError)
      end
    end
  end

  describe "input length guard" do
    it "raises ArgumentError above MAX_INPUT_LENGTH" do
      expect { Pubid::Ietf.parse("RFC #{'1' * Pubid::MAX_INPUT_LENGTH}") }
        .to raise_error(ArgumentError, /maximum length/)
    end
  end
end
