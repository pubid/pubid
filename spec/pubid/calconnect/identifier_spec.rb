# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Calconnect::Identifier do
  describe ".parse" do
    shared_examples "a CalConnect standard" do |input, series:, number:, date:|
      describe input do
        let(:parsed) { described_class.parse(input) }

        it "builds a Standard" do
          expect(parsed).to be_a(Pubid::Calconnect::Identifiers::Standard)
        end

        it "parses series == #{series.inspect}" do
          expect(parsed.series).to eq(series)
        end

        it "parses number == #{number.inspect}" do
          expect(parsed.number).to eq(number)
        end

        it "parses the date as #{date.inspect}" do
          expect(parsed.date).to be_a(Pubid::Components::Date)
          expect(parsed.date_string).to eq(date)
        end

        it "round-trips via to_s" do
          expect(parsed.to_s).to eq(input)
        end
      end
    end

    context "bare (no series)" do
      it_behaves_like "a CalConnect standard", "CC 18011:2018",
                      series: nil, number: "18011", date: "2018"
    end

    context "with a series" do
      it_behaves_like "a CalConnect standard", "CC/DIR 10006:2019",
                      series: "DIR", number: "10006", date: "2019"
      it_behaves_like "a CalConnect standard", "CC/R 18003:2019",
                      series: "R", number: "18003", date: "2019"
      it_behaves_like "a CalConnect standard", "CC/A 0001:2000",
                      series: "A", number: "0001", date: "2000"
    end

    context "decimal (dot) sub-part number" do
      it_behaves_like "a CalConnect standard", "CC/Adv 0707.1:2007",
                      series: "Adv", number: "0707.1", date: "2007"
    end

    context "dashed sub-part number" do
      it_behaves_like "a CalConnect standard", "CC/A 0812-1:2008",
                      series: "A", number: "0812-1", date: "2008"
    end

    context "full ISO date after the colon" do
      it_behaves_like "a CalConnect standard", "CC/WD 51017:2024-07-23",
                      series: "WD", number: "51017", date: "2024-07-23"

      it "splits the date into year, month and day" do
        parsed = described_class.parse("CC/WD 51017:2024-07-23")
        expect(parsed.date.year).to eq("2024")
        expect(parsed.date.month).to eq("07")
        expect(parsed.date.day).to eq("23")
      end
    end

    context "rendering without the publisher token" do
      it "drops the CC and series slash for a series id" do
        parsed = described_class.parse("CC/DIR 10006:2019")
        expect(parsed.to_s(with_publisher: false)).to eq("DIR 10006:2019")
      end

      it "drops the CC for a bare id" do
        parsed = described_class.parse("CC 18011:2018")
        expect(parsed.to_s(with_publisher: false)).to eq("18011:2018")
      end

      it "does not leak the flag into a later default render" do
        parsed = described_class.parse("CC/DIR 10006:2019")
        parsed.to_s(with_publisher: false)
        expect(parsed.to_s).to eq("CC/DIR 10006:2019")
      end
    end

    context "input length guard" do
      it "rejects an over-long string" do
        expect { described_class.parse("CC #{'1' * 1001}:2018") }
          .to raise_error(ArgumentError)
      end
    end
  end
end
