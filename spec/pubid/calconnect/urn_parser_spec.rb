# frozen_string_literal: true

require "spec_helper"
require_relative "../../support/urn_round_trip"

RSpec.describe Pubid::Calconnect::UrnParser do
  it_behaves_like "flavor URN round-trip", Pubid::Calconnect, [
    "CC 18011:2018",
    "CC/DIR 10006:2019",
    "CC/A 0812-1:2008",
    "CC/Adv 0707.1:2007",
    "CC/WD 51017:2024-07-23",
  ]
end
