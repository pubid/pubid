# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/nist"
require_relative "../../support/urn_round_trip"

RSpec.describe Pubid::Nist::UrnParser do
  it_behaves_like "flavor URN round-trip", Pubid::Nist, [
    "NIST SP 800-53",
    "NIST SP 800-53r5",
    "NIST FIPS 199",
    "NIST IR 8202",
  ]
end
