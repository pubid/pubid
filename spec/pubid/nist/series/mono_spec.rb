# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Nist::Series::Mono do
  it "inherits from LetterPreserving" do
    expect(described_class).to be < Pubid::Nist::Series::LetterPreserving
  end

  describe ".cast_letter_number" do
    it "preserves letter suffix as raw value (not Part)" do
      result = described_class.cast_letter_number(
        { letter_base: "1", letter_suffix: "A" }, {}
      )
      expect(result).to eq({ letter_base: "1", letter_suffix: "A" })
    end
  end
end
