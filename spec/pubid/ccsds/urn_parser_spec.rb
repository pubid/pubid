# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/ccsds"
require_relative "../../support/urn_round_trip"

RSpec.describe Pubid::Ccsds::UrnParser do
  it_behaves_like "flavor URN round-trip", Pubid::Ccsds, [
    "CCSDS 120.0-G-4",
    "CCSDS 100.0-G-1-S",
  ]
end
