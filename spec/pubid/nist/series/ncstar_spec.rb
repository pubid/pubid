# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Nist::Series::Ncstar do
  it "inherits from Base (NOT LetterPreserving)" do
    expect(described_class).to be < Pubid::Nist::Series::Base
    expect(described_class).not_to be < Pubid::Nist::Series::LetterPreserving
  end

  describe ".preserve_letter_suffix?" do
    it "returns false (first_number letter is NOT preserved)" do
      expect(described_class.preserve_letter_suffix?({})).to be(false)
    end
  end

  describe ".cast_letter_number" do
    it "preserves letter suffix as raw value" do
      result = described_class.cast_letter_number(
        { letter_base: "1", letter_suffix: "A" }, {}
      )
      expect(result).to eq({ letter_base: "1", letter_suffix: "A" })
    end
  end
end
