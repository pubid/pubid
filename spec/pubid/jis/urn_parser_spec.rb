# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/jis"
require_relative "../../support/urn_round_trip"

RSpec.describe Pubid::Jis::UrnParser do
  it_behaves_like "flavor URN round-trip", Pubid::Jis, [
    "JIS X 0201:1997",
  ]
end
