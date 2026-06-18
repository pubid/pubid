# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/oiml"
require_relative "../../support/urn_round_trip"

RSpec.describe Pubid::Oiml::UrnParser do
  it_behaves_like "flavor URN round-trip", Pubid::Oiml, [
    "OIML R 111-1",
    "OIML D 1",
  ]
end
