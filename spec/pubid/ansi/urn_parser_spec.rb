# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/ansi"
require_relative "../../support/urn_round_trip"

RSpec.describe Pubid::Ansi::UrnParser do
  it_behaves_like "flavor URN round-trip", Pubid::Ansi, [
    "ANSI X3.4:1963",
  ]
end
