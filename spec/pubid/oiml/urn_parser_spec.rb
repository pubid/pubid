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
end
