# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Nist::Series::Crpl do
  it "inherits from LetterPreserving" do
    expect(described_class).to be < Pubid::Nist::Series::LetterPreserving
  end

  it "uses default (non-modern) edition date" do
    expect(described_class.modern_edition_date?).to be(false)
  end
end
