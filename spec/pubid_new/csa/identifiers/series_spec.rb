# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Csa::Identifiers::Series do
  describe ".parse" do
    context "series with series prefix" do
      describe "CSA Z240 MH SERIES:16 (R2025)" do
        subject { "CSA Z240 MH SERIES:16 (R2025)" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses as Series" do
          expect(parsed).to be_a(described_class)
        end

        it "parses code" do
          expect(parsed.code.value).to eq("Z240")
        end

        it "parses series prefix" do
          expect(parsed.series_prefix).to eq("MH")
        end

        it "parses year" do
          expect(parsed.year).to eq("2016")
        end

        it "parses reaffirmation" do
          expect(parsed.reaffirmation).to eq("2025")
        end

        it "uses colon format" do
          expect(parsed.year_format).to eq("colon")
        end

        it "round-trips correctly" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "CSA Z240 RV SERIES:23" do
        subject { "CSA Z240 RV SERIES:23" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses as Series" do
          expect(parsed).to be_a(described_class)
        end

        it "parses code" do
          expect(parsed.code.value).to eq("Z240")
        end

        it "parses RV series prefix" do
          expect(parsed.series_prefix).to eq("RV")
        end

        it "parses year" do
          expect(parsed.year).to eq("2023")
        end

        it "round-trips correctly" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "series without series prefix" do
      describe "CSA Z245.20 SERIES:22" do
        subject { "CSA Z245.20 SERIES:22" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses as Series" do
          expect(parsed).to be_a(described_class)
        end

        it "parses code" do
          expect(parsed.code.value).to eq("Z245.20")
        end

        it "has no series prefix" do
          expect(parsed.series_prefix).to be_nil
        end

        it "parses year" do
          expect(parsed.year).to eq("2022")
        end

        it "round-trips correctly" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "CSA Z341 SERIES:22" do
        subject { "CSA Z341 SERIES:22" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses as Series" do
          expect(parsed).to be_a(described_class)
        end

        it "parses code" do
          expect(parsed.code.value).to eq("Z341")
        end

        it "has no series prefix" do
          expect(parsed.series_prefix).to be_nil
        end

        it "parses year" do
          expect(parsed.year).to eq("2022")
        end

        it "round-trips correctly" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "CAN/CSA prefixed series with dash year" do
      describe "CAN/CSA-A220 SERIES-06 (R2021)" do
        subject { "CAN/CSA-A220 SERIES-06 (R2021)" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses as Series" do
          expect(parsed).to be_a(described_class)
        end

        it "parses publisher prefix" do
          expect(parsed.publisher_prefix).to eq("CAN/CSA-")
        end

        it "parses code" do
          expect(parsed.code.value).to eq("A220")
        end

        it "parses year" do
          expect(parsed.year).to eq("2006")
        end

        it "parses reaffirmation" do
          expect(parsed.reaffirmation).to eq("2021")
        end

        it "uses dash format" do
          expect(parsed.year_format).to eq("dash")
        end

        it "round-trips correctly" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "CAN/CSA-B45 SERIES-02 (R2013)" do
        subject { "CAN/CSA-B45 SERIES-02 (R2013)" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses code" do
          expect(parsed.code.value).to eq("B45")
        end

        it "parses year" do
          expect(parsed.year).to eq("2002")
        end

        it "parses reaffirmation" do
          expect(parsed.reaffirmation).to eq("2013")
        end

        it "round-trips correctly" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "CAN/CSA-C448 SERIES-13" do
        subject { "CAN/CSA-C448 SERIES-13" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses code" do
          expect(parsed.code.value).to eq("C448")
        end

        it "parses year" do
          expect(parsed.year).to eq("2013")
        end

        it "round-trips correctly" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "CAN/CSA-F378 SERIES-11 (R2016)" do
        subject { "CAN/CSA-F378 SERIES-11 (R2016)" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses code" do
          expect(parsed.code.value).to eq("F378")
        end

        it "parses year" do
          expect(parsed.year).to eq("2011")
        end

        it "parses reaffirmation" do
          expect(parsed.reaffirmation).to eq("2016")
        end

        it "round-trips correctly" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "series with NO. notation" do
      describe "CAN/CSA-C22.2 NO. 231 SERIES-M89 (R2001)" do
        subject { "CAN/CSA-C22.2 NO. 231 SERIES-M89 (R2001)" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses as Series" do
          expect(parsed).to be_a(described_class)
        end

        it "parses code (NO. normalized to dash)" do
          expect(parsed.code.value).to eq("C22.2-231")
        end

        it "parses year prefix" do
          expect(parsed.year_prefix).to eq("M")
        end

        it "parses year" do
          expect(parsed.year).to eq("1989")
        end

        it "parses reaffirmation" do
          expect(parsed.reaffirmation).to eq("2001")
        end

        it "round-trips in normalized form" do
          expect(parsed.to_s).to eq("CAN/CSA-C22.2-231 SERIES-M89 (R2001)")
        end
      end
    end

    context "CSA A165 SERIES:14 (R2024)" do
      describe "CSA A165 SERIES:14 (R2024)" do
        subject { "CSA A165 SERIES:14 (R2024)" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses as Series" do
          expect(parsed).to be_a(described_class)
        end

        it "parses code" do
          expect(parsed.code.value).to eq("A165")
        end

        it "parses year" do
          expect(parsed.year).to eq("2014")
        end

        it "parses reaffirmation" do
          expect(parsed.reaffirmation).to eq("2024")
        end

        it "round-trips correctly" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "CSA B139 SERIES:19" do
      describe "CSA B139 SERIES:19" do
        subject { "CSA B139 SERIES:19" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses code" do
          expect(parsed.code.value).to eq("B139")
        end

        it "parses year" do
          expect(parsed.year).to eq("2019")
        end

        it "round-trips correctly" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "CSA B139 SERIES:24" do
      describe "CSA B139 SERIES:24" do
        subject { "CSA B139 SERIES:24" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses code" do
          expect(parsed.code.value).to eq("B139")
        end

        it "parses year as 2024" do
          expect(parsed.year).to eq("2024")
        end

        it "round-trips correctly" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end
  end
end