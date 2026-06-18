# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/csa"
require_relative "../../support/urn_round_trip"

RSpec.describe Pubid::Csa::UrnParser do
  it_behaves_like "flavor URN round-trip", Pubid::Csa, [
    "CSA Z240.2.1-16",
  ]
end
