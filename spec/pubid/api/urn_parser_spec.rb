# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/api"
require_relative "../../support/urn_round_trip"

RSpec.describe Pubid::Api::UrnParser do
  it_behaves_like "flavor URN round-trip", Pubid::Api, [
    "API STD 1104",
    "API STD 1104-1:2020",
    "API RP 500",
  ]
end
