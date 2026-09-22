# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/oiml"
require_relative "../../support/urn_round_trip"

RSpec.describe Pubid::Oiml::UrnParser do
  it_behaves_like "flavor URN round-trip", Pubid::Oiml, [
    "OIML R 111-1",
    "OIML D 1",
    # Bulletin — every tier of the periodical hierarchy round-trips through
    # the URN, including the bare periodical (no locator).
    "OIML Bulletin",
    "OIML Bulletin 1960",
    "OIML Bulletin 1960-03",
    "OIML Bulletin 1960-03-01",
    # Citation form URN-canonicalizes to structured on the way out, so the
    # round-trip lands on the structured form.
    "OIML Bulletin 2026-02-11",
  ]

  # A dual-published id's URN represents only the OIML side (there is no
  # joint URN scheme in this codebase), so it is not part of the shared
  # round-trip list above — a URN never re-parses back into a DualPublished
  # wrapper, only into a plain Recommendation.
  it "generates a URN for the OIML side only" do
    id = Pubid::Oiml.parse("ISO 4064-1:2024|OIML R 49-1:2024")
    expect(id.to_urn).to eq("urn:oiml:r:49-1:2024")
  end
end
