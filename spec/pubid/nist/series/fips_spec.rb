# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Nist::Series::Fips do
  it "inherits from LetterPreserving" do
    expect(described_class).to be < Pubid::Nist::Series::LetterPreserving
  end

  describe ".modern_edition_date?" do
    it "returns true (FIPS uses numeric date format)" do
      expect(described_class.modern_edition_date?).to be(true)
    end
  end
end
