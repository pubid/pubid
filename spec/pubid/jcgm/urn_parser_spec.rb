# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/jcgm"
require_relative "../../support/urn_round_trip"

RSpec.describe Pubid::Jcgm::UrnParser do
  it_behaves_like "flavor URN round-trip", Pubid::Jcgm, [
    "JCGM 200:2012",
    "JCGM 100:2008",
    "JCGM 17th Meeting (2012)",
    "JCGM 11st Meeting (2006)",
    "JCGM GUM",
    "JCGM VIM-3",
  ]
end
