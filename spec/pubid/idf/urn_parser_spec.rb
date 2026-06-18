# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/idf"
require_relative "../../support/urn_round_trip"

RSpec.describe Pubid::Idf::UrnParser do
  it_behaves_like "flavor URN round-trip", Pubid::Idf, [
    "IDF 87:2019",
    "IDF 100",
  ]
end
