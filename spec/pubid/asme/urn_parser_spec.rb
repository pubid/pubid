# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/asme"
require_relative "../../support/urn_round_trip"

RSpec.describe Pubid::Asme::UrnParser do
  it_behaves_like "flavor URN round-trip", Pubid::Asme, [
    "ASME B16.5-2020",
    "ASME PTC 1-2020",
    "ASME BPVC-2023",
  ]
end
