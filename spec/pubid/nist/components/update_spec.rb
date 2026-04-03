# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Nist::Components::Update do
  describe "initialization" do
    it "creates update with number, year, and month" do
      update = described_class.new(number: "1", year: "2021", month: "2")
      expect(update.number).to eq("1")
      expect(update.year).to eq("2021")
      expect(update.month).to eq("2")
    end

    it "creates update with number and year only" do
      update = described_class.new(number: "3", year: "2015")
      expect(update.number).to eq("3")
      expect(update.year).to eq("2015")
      expect(update.month).to be_nil
    end

    it "creates update with number only" do
      update = described_class.new(number: "1")
      expect(update.number).to eq("1")
      expect(update.year).to be_nil
      expect(update.month).to be_nil
    end
  end

  describe "#to_s" do
    context "short format" do
      it "renders update with year and month" do
        update = described_class.new(number: "1", year: "2021", month: "2")
        expect(update.to_s(:short)).to eq("/Upd1-202102")
      end

      it "renders update with year only" do
        update = described_class.new(number: "3", year: "2015")
        expect(update.to_s(:short)).to eq("/Upd3-2015")
      end

      it "renders update with single digit month" do
        update = described_class.new(number: "1", year: "2021", month: "2")
        expect(update.to_s(:short)).to eq("/Upd1-202102")
      end

      it "renders update with double digit month" do
        update = described_class.new(number: "1", year: "2021", month: "11")
        expect(update.to_s(:short)).to eq("/Upd1-202111")
      end

      it "renders update number 2 with year and month" do
        update = described_class.new(number: "2", year: "2020", month: "6")
        expect(update.to_s(:short)).to eq("/Upd2-202006")
      end

      it "renders update with number only (no year)" do
        update = described_class.new(number: "1")
        expect(update.to_s(:short)).to eq("/Upd1")
      end
    end

    context "mr (machine-readable) format" do
      it "renders update with year and month" do
        update = described_class.new(number: "1", year: "2021", month: "2")
        expect(update.to_s(:mr)).to eq("-upd1-202102")
      end

      it "renders update with year only" do
        update = described_class.new(number: "3", year: "2015")
        expect(update.to_s(:mr)).to eq("-upd3-2015")
      end

      it "renders update number 2 with year and month" do
        update = described_class.new(number: "2", year: "2020", month: "6")
        expect(update.to_s(:mr)).to eq("-upd2-202006")
      end

      it "renders update with number only (no year)" do
        update = described_class.new(number: "1")
        expect(update.to_s(:mr)).to eq("-upd1")
      end
    end

    context "long format" do
      it "renders update with year and month" do
        update = described_class.new(number: "1", year: "2021", month: "2")
        expect(update.to_s(:long)).to eq("Update 1-2021 February")
      end

      it "renders update with year only" do
        update = described_class.new(number: "3", year: "2015")
        expect(update.to_s(:long)).to eq("Update 3-2015")
      end

      it "renders update with month name" do
        update = described_class.new(number: "1", year: "2021", month: "6")
        expect(update.to_s(:long)).to eq("Update 1-2021 June")
      end

      it "renders update with December" do
        update = described_class.new(number: "1", year: "2021", month: "12")
        expect(update.to_s(:long)).to eq("Update 1-2021 December")
      end

      it "renders update with number only (no year)" do
        update = described_class.new(number: "1")
        expect(update.to_s(:long)).to eq("Update 1")
      end
    end

    context "default format" do
      it "uses short format when no format specified" do
        update = described_class.new(number: "1", year: "2021", month: "2")
        expect(update.to_s).to eq("/Upd1-202102")
      end
    end

    context "nil number" do
      it "returns empty string when number is nil" do
        update = described_class.new(number: nil, year: "2021", month: "2")
        expect(update.to_s).to eq("")
      end

      it "returns empty string for nil number in mr format" do
        update = described_class.new(number: nil, year: "2021", month: "2")
        expect(update.to_s(:mr)).to eq("")
      end

      it "returns empty string for nil number in long format" do
        update = described_class.new(number: nil, year: "2021", month: "2")
        expect(update.to_s(:long)).to eq("")
      end
    end
  end

  describe "month formatting" do
    it "pads single digit month with zero" do
      update = described_class.new(number: "1", year: "2021", month: "2")
      expect(update.to_s(:short)).to eq("/Upd1-202102")
    end

    it "does not pad double digit month" do
      update = described_class.new(number: "1", year: "2021", month: "12")
      expect(update.to_s(:short)).to eq("/Upd1-202112")
    end

    it "renders month name correctly in long format" do
      update = described_class.new(number: "1", year: "2021", month: "1")
      expect(update.to_s(:long)).to eq("Update 1-2021 January")
    end
  end

  describe "year-month string building" do
    it "concatenates year and month correctly" do
      update = described_class.new(number: "1", year: "2021", month: "6")
      expect(update.to_s(:short)).to eq("/Upd1-202106")
    end

    it "uses year only when month is nil" do
      update = described_class.new(number: "3", year: "2015")
      expect(update.to_s(:short)).to eq("/Upd3-2015")
    end
  end
end
