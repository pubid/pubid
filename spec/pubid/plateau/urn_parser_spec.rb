# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/plateau"
require_relative "../../support/urn_round_trip"

RSpec.describe Pubid::Plateau::UrnParser do
  it_behaves_like "flavor URN round-trip", Pubid::Plateau, [
    "PLATEAU Handbook #00",
  ]
end
