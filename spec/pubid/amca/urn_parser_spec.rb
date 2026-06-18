# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/amca"
require_relative "../../support/urn_round_trip"

RSpec.describe Pubid::Amca::UrnParser do
  it_behaves_like "flavor URN round-trip", Pubid::Amca, [
    "AMCA 210-08",
  ]
end
