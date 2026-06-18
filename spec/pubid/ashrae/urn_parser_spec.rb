# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/ashrae"
require_relative "../../support/urn_round_trip"

RSpec.describe Pubid::Ashrae::UrnParser do
  it_behaves_like "flavor URN round-trip", Pubid::Ashrae, [
    "ASHRAE Standard 90.1-2019",
  ]
end
