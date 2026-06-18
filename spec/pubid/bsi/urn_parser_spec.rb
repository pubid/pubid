# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/bsi"
require_relative "../../support/urn_round_trip"

RSpec.describe Pubid::Bsi::UrnParser do
  it_behaves_like "flavor URN round-trip", Pubid::Bsi, [
    "BS 9001:2015",
    "BS 9001:2015/Amd 1:2020",
  ]
end
