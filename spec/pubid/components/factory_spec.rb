# frozen_string_literal: true

require "spec_helper"
require_relative "../../../lib/pubid/components/factory"

RSpec.describe Pubid::Components::Factory do
  describe ".from_hash" do
    it "wraps :publisher into a Publisher Component" do
      result = described_class.from_hash(publisher: "ISO")
      expect(result[:publisher]).to be_a(Pubid::Components::Publisher)
      expect(result[:publisher].body).to eq("ISO")
    end

    it "wraps :number, :part, :subpart into Code Components" do
      result = described_class.from_hash(number: "19115", part: "1",
                                         subpart: "2")
      expect(result[:number]).to be_a(Pubid::Components::Code)
      expect(result[:number].value).to eq("19115")
      expect(result[:part].value).to eq("1")
      expect(result[:subpart].value).to eq("2")
    end

    it "coerces non-string values via to_s for Code fields" do
      result = described_class.from_hash(part: 1)
      expect(result[:part].value).to eq("1")
    end

    it "wraps :edition into an Edition Component, preserving raw value type" do
      result = described_class.from_hash(edition: 9)
      expect(result[:edition]).to be_a(Pubid::Components::Edition)
      expect(result[:edition].number).to eq(9)
    end

    it "renames :year to :date and wraps in a Date Component" do
      result = described_class.from_hash(year: "2014")
      expect(result).not_to have_key(:year)
      expect(result[:date]).to be_a(Pubid::Components::Date)
      expect(result[:date].year).to eq("2014")
    end

    it "renames :language to :languages and wraps in an Array<Language>" do
      result = described_class.from_hash(language: "en")
      expect(result).not_to have_key(:language)
      expect(result[:languages]).to be_an(Array)
      expect(result[:languages].first).to be_a(Pubid::Components::Language)
    end

    it "passes unknown keys through unchanged" do
      sentinel = Object.new
      result = described_class.from_hash(some_future_attr: sentinel)
      expect(result[:some_future_attr]).to equal(sentinel)
    end

    it "drops nil values" do
      result = described_class.from_hash(publisher: "ISO", part: nil,
                                         year: nil)
      expect(result.keys).to eq([:publisher])
    end

    it "returns an empty hash for an empty input" do
      expect(described_class.from_hash({})).to eq({})
    end

    it "does not mutate the input hash" do
      input = { publisher: "ISO", year: "2014" }
      input_copy = input.dup
      described_class.from_hash(input)
      expect(input).to eq(input_copy)
    end
  end

  describe "KEY_RENAMES" do
    it "documents the 1.x → 2.x attribute renames" do
      expect(described_class::KEY_RENAMES).to eq(
        year: :date,
        language: :languages,
      )
    end
  end
end
