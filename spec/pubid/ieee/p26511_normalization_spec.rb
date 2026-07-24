# frozen_string_literal: true

require "spec_helper"

RSpec.describe "ISO/IEC DIS P26511.2 normalization — issue #212" do
  # The prior mapping pointed to "ISO/IEC DIS P26511-2", which is a phantom
  # document — ISO/IEC 26511 has no part 2. The ".2" is an IEEE-style draft
  # version marker, not an ISO part. The new mapping normalizes to a real
  # ISO DIS form.

  it "UpdateCodes rewrites the IEEE-style citation to a real ISO DIS form" do
    normalized = Pubid::Core::UpdateCodes.apply(
      "ISO/IEC DIS P26511.2, May 2017", :ieee,
    )
    expect(normalized).to eq("ISO/IEC DIS 26511.2:2017")
  end

  it "the normalized form parses as an ISO identifier" do
    expect { Pubid::Iso.parse("ISO/IEC DIS 26511.2:2017") }.not_to raise_error
  end

  it "the prior phantom form no longer appears in the rewrite" do
    normalized = Pubid::Core::UpdateCodes.apply(
      "ISO/IEC DIS P26511.2, May 2017", :ieee,
    )
    expect(normalized).not_to include("P26511-2")
  end
end
