# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Nist::Series::LetterPreserving do
  it "inherits from Base" do
    expect(described_class).to be < Pubid::Nist::Series::Base
  end

  describe ".preserve_letter_suffix?" do
    it "returns true regardless of parsed_format" do
      expect(described_class.preserve_letter_suffix?({})).to be(true)
      expect(described_class.preserve_letter_suffix?(parsed_format: :short))
        .to be(true)
    end
  end
end
