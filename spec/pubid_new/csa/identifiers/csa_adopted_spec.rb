# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Csa::Identifiers::CsaAdopted do
  describe ".parse" do
    context "CSA ISO/IEC patterns" do
      describe "CSA ISO/IEC 8824-1:22" do
        subject { "CSA ISO/IEC 8824-1:22" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses as CsaAdopted" do
          expect(parsed).to be_a(described_class)
        end

        it "parses wrapped ISO/IEC identifier" do
          expect(parsed.wrapped_identifier).to be_a(PubidNew::Iso::Identifiers::InternationalStandard)
        end

        it "parses number" do
          expect(parsed.wrapped_identifier.number.value).to eq("8824-1")
        end

        it "parses year as 2-digit in rendering" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "CSA ISO/IEC 9594-2:21" do
        subject { "CSA ISO/IEC 9594-2:21" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses multi-part number" do
          expect(parsed.wrapped_identifier.number.value).to eq("9594-2")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "CSA ISO/IEC 9594-2:21/A1:22" do
        subject { "CSA ISO/IEC 9594-2:21/A1:22" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses as CsaAdopted with amendment" do
          expect(parsed).to be_a(described_class)
        end

        it "parses wrapped amendment" do
          expect(parsed.wrapped_identifier).to be_a(PubidNew::Iso::Identifiers::Amendment)
        end

        it "parses amendment number" do
          expect(parsed.wrapped_identifier.number.value).to eq("1")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "CSA ISO/IEC TR patterns" do
      describe "CSA ISO/IEC TR 19758:04 (R2024)" do
        subject { "CSA ISO/IEC TR 19758:04 (R2024)" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses as CsaAdopted" do
          expect(parsed).to be_a(described_class)
        end

        it "parses wrapped Technical Report" do
          expect(parsed.wrapped_identifier).to be_a(PubidNew::Iso::Identifiers::TechnicalReport)
        end

        it "parses reaffirmation" do
          expect(parsed.reaffirmation).to eq("2024")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "CSA ISO/IEC TR 19758:04/A1:06 (R2024)" do
        subject { "CSA ISO/IEC TR 19758:04/A1:06 (R2024)" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses TR with amendment" do
          expect(parsed.wrapped_identifier).to be_a(PubidNew::Iso::Identifiers::Amendment)
        end

        it "parses amendment number" do
          expect(parsed.wrapped_identifier.number.value).to eq("1")
        end

        it "parses reaffirmation" do
          expect(parsed.reaffirmation).to eq("2024")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "CSA ISO/IEC TR 12785-3:15" do
        subject { "CSA ISO/IEC TR 12785-3:15" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses multi-part TR number" do
          expect(parsed.wrapped_identifier.number.value).to eq("12785-3")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "CAN/CSA-ISO patterns" do
      describe "CAN/CSA-ISO 10012:03 (R2023)" do
        subject { "CAN/CSA-ISO 10012:03 (R2023)" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses as CanadianAdopted wrapping CsaAdopted" do
          expect(parsed).to be_a(PubidNew::Csa::Identifiers::CanadianAdopted)
        end

        it "wrapped identifier is CsaAdopted" do
          expect(parsed.wrapped_identifier).to be_a(described_class)
        end

        it "parses ISO number" do
          expect(parsed.wrapped_identifier.wrapped_identifier.number.value).to eq("10012")
        end

        it "parses reaffirmation" do
          expect(parsed.reaffirmation).to eq("2023")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "CAN/CSA-ISO 10819:16" do
        subject { "CAN/CSA-ISO 10819:16" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses nested adoption structure" do
          expect(parsed).to be_a(PubidNew::Csa::Identifiers::CanadianAdopted)
          expect(parsed.wrapped_identifier).to be_a(described_class)
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "CAN/CSA-IEC patterns" do
      describe "CAN/CSA-IEC 61000-4-2:12 (R2022)" do
        subject { "CAN/CSA-IEC 61000-4-2:12 (R2022)" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses as CanadianAdopted" do
          expect(parsed).to be_a(PubidNew::Csa::Identifiers::CanadianAdopted)
        end

        it "wrapped identifier is CsaAdopted" do
          expect(parsed.wrapped_identifier).to be_a(described_class)
        end

        it "parses IEC number" do
          expect(parsed.wrapped_identifier.wrapped_identifier.number.value).to eq("61000-4-2")
        end

        it "parses reaffirmation" do
          expect(parsed.reaffirmation).to eq("2022")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "CAN/CSA-IEC 62443-2-4:17/A1:20 (R2022)" do
        subject { "CAN/CSA-IEC 62443-2-4:17/A1:20 (R2022)" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses IEC with amendment" do
          expect(parsed.wrapped_identifier.wrapped_identifier).to be_a(PubidNew::Iec::Identifiers::Amendment)
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "CAN/CSA-CEI/IEC patterns (bilingual)" do
      describe "CAN/CSA-CEI/IEC 61000-4-28-01 (R2022)" do
        subject { "CAN/CSA-CEI/IEC 61000-4-28-01 (R2022)" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses as CanadianAdopted" do
          expect(parsed).to be_a(PubidNew::Csa::Identifiers::CanadianAdopted)
        end

        it "parses CEI/IEC copublisher format" do
          expect(parsed.wrapped_identifier.wrapped_identifier.publisher.to_s).to eq("IEC")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "CAN/CSA-CEI/IEC 61000-4-28-01/A1:03 (R2022)" do
        subject { "CAN/CSA-CEI/IEC 61000-4-28-01/A1:03 (R2022)" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses amendment with CEI/IEC" do
          expect(parsed.wrapped_identifier.wrapped_identifier).to be_a(PubidNew::Iec::Identifiers::Amendment)
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "CSA ISO patterns (without IEC)" do
      describe "CAN/CSA-ISO 9001:16 (R2025)" do
        subject { "CAN/CSA-ISO 9001:16 (R2025)" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses as CanadianAdopted" do
          expect(parsed).to be_a(PubidNew::Csa::Identifiers::CanadianAdopted)
        end

        it "wrapped identifier is CsaAdopted" do
          expect(parsed.wrapped_identifier).to be_a(described_class)
        end

        it "parses ISO number" do
          expect(parsed.wrapped_identifier.wrapped_identifier.number.value).to eq("9001")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "reaffirmation patterns" do
      describe "CSA ISO/IEC 8859-16:02 (R2021)" do
        subject { "CSA ISO/IEC 8859-16:02 (R2021)" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses reaffirmation" do
          expect(parsed.reaffirmation).to eq("2021")
        end

        it "preserves 2-digit year in rendering" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end
  end
end
