# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/cen_cenelec"
require_relative "../../support/urn_round_trip"

RSpec.describe Pubid::CenCenelec::UrnParser do
  it_behaves_like "flavor URN round-trip", Pubid::CenCenelec, [
    "EN 9001:2015",
  ]
end
