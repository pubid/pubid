# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/etsi"
require_relative "../../support/urn_round_trip"

RSpec.describe Pubid::Etsi::UrnParser do
  it_behaves_like "flavor URN round-trip", Pubid::Etsi, [
    "ETSI EN 300 100 V1.1.1 (1998-04)",
  ]
end
