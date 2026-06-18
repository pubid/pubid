# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/ieee"
require_relative "../../support/urn_round_trip"

RSpec.describe Pubid::Ieee::UrnParser do
  it_behaves_like "flavor URN round-trip", Pubid::Ieee, [
    "IEEE Std 802.3-2018",
    "IEEE Std 1018-2019",
  ]
end
