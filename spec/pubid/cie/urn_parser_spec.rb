# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/cie"
require_relative "../../support/urn_round_trip"

RSpec.describe Pubid::Cie::UrnParser do
  it_behaves_like "flavor URN round-trip", Pubid::Cie, [
    "CIE 015:2018",
  ]
end
