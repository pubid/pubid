# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Nist::Series::Ir do
  describe ".cast_letter_number" do
    it "preserves 'R' suffix as raw value for builder revision handling" do
      result = described_class.cast_letter_number(
        { letter_base: "1786", letter_suffix: "R" }, {}
      )
      expect(result).to eq({ letter_base: "1786", letter_suffix: "R" })
    end

    it "preserves 'Ur' suffix as raw value" do
      result = described_class.cast_letter_number(
        { letter_base: "197", letter_suffix: "U", letter_suffix_extra: "r" },
        {},
      )
      expect(result).to eq(
        { letter_base: "197", letter_suffix: "U",
          letter_suffix_extra: "r" }.merge(letter_suffix: "Ur"),
      )
    end

    it "splits non-R suffix into a Part component" do
      result = described_class.cast_letter_number(
        { letter_base: "56", letter_suffix: "A" }, {}
      )
      expect(result).to eq(
        part: Pubid::Nist::Components::Part.new(type: "", value: "A"),
      )
    end
  end

  describe ".part_num_as_component?" do
    it "returns true (IR treats part_num as a Part component)" do
      expect(described_class.part_num_as_component?).to be(true)
    end
  end

  describe ".handle_letter_num_compound?" do
    let(:identifier) { Pubid::Nist::Identifiers::InteragencyReport.new }
    let(:first_num) do
      Pubid::Nist::Components::Code.new(value: "79")
    end

    it "converts 'R' suffix to revision r1" do
      handled = described_class.handle_letter_num_compound?(
        identifier,
        first_num: first_num, letter_base: "1786", letter_suffix: "R",
      )
      expect(handled).to be(true)
      expect(identifier.number.value).to eq("79-1786")
      expect(identifier.edition.id).to eq("1")
      expect(identifier.edition.type).to eq("r")
      expect(identifier.revision).to eq("r1")
    end

    it "does not handle non-R suffix" do
      handled = described_class.handle_letter_num_compound?(
        identifier,
        first_num: first_num, letter_base: "56", letter_suffix: "A",
      )
      expect(handled).to be(false)
    end
  end

  describe ".finalize_identifier" do
    let(:identifier) { Pubid::Nist::Identifiers::InteragencyReport.new }

    it "reverses '84e2946' back to compound '84-2946'" do
      identifier.number = Pubid::Nist::Components::Code.new(value: "84e2946")
      identifier.edition = Pubid::Nist::Components::Edition.new(type: "e",
                                                                id: "2946")
      described_class.finalize_identifier(identifier, {})
      expect(identifier.number.value).to eq("84-2946")
      expect(identifier.edition).to be_nil
    end

    it "leaves non-e-suffixed numbers untouched" do
      identifier.number = Pubid::Nist::Components::Code.new(value: "84-2946")
      described_class.finalize_identifier(identifier, {})
      expect(identifier.number.value).to eq("84-2946")
    end
  end
end
