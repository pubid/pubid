# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/astm"
require_relative "../../support/urn_round_trip"

RSpec.describe Pubid::Astm::UrnParser do
  it_behaves_like "flavor URN round-trip", Pubid::Astm, [
    "ASTM D2148-22",
    "ASTM A1-02",
  ]
end
