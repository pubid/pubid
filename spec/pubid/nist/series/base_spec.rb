# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Nist::Series::Base do
  describe ".preserve_letter_suffix?" do
    it "returns false by default" do
      expect(described_class.preserve_letter_suffix?({})).to be(false)
    end

    it "returns true when parsed_format is :mr" do
      expect(described_class.preserve_letter_suffix?(parsed_format: :mr))
        .to be(true)
    end
  end

  describe ".cast_letter_number" do
    it "returns nil for empty letter_suffix" do
      result = described_class.cast_letter_number({ letter_suffix: "" }, {})
      expect(result).to be_nil
    end

    it "splits letter suffix into a Part component by default" do
      result = described_class.cast_letter_number({ letter_suffix: "A" }, {})
      expect(result).to eq(
        part: Pubid::Nist::Components::Part.new(type: "", value: "A"),
      )
    end

    it "combines letter_suffix and letter_suffix_extra" do
      result = described_class.cast_letter_number(
        { letter_suffix: "U", letter_suffix_extra: "r" }, {}
      )
      expect(result).to eq(
        part: Pubid::Nist::Components::Part.new(type: "", value: "UR"),
      )
    end
  end

  describe ".modern_edition_date?" do
    it "returns false by default" do
      expect(described_class.modern_edition_date?).to be(false)
    end
  end

  describe ".part_num_as_component?" do
    it "returns false by default" do
      expect(described_class.part_num_as_component?).to be(false)
    end
  end

  describe ".handle_letter_num_compound?" do
    it "returns false (no-op)" do
      identifier = Pubid::Nist::Identifiers::Base.new
      result = described_class.handle_letter_num_compound?(
        identifier,
        first_num: nil, letter_base: "1", letter_suffix: "R",
      )
      expect(result).to be(false)
    end
  end

  describe ".finalize_identifier" do
    it "does nothing by default" do
      identifier = Pubid::Nist::Identifiers::Base.new
      expect { described_class.finalize_identifier(identifier, {}) }
        .not_to(change { identifier })
    end
  end
end
