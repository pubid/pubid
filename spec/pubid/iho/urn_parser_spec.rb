# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/iho"
require_relative "../../support/urn_round_trip"

RSpec.describe Pubid::Iho::UrnParser do
  it_behaves_like "flavor URN round-trip", Pubid::Iho, [
    "IHO S-44 5.0.0",
    "IHO S-100 Part 4a 1.0.0",
    "IHO S-65 Ap. A 1.0.0",
    "IHO S-100 Annex A 5.2.0",
    "IHO S-66 Suppl 1 2.0.0",
  ]
end
