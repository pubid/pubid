# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/oasis"
require_relative "../../support/urn_round_trip"

RSpec.describe Pubid::Oasis::UrnParser do
  it_behaves_like "flavor URN round-trip", Pubid::Oasis, [
    "OASIS amqp-core",                     # bare spec
    "OASIS WSDM-v1.1",                     # spec + version
    "OASIS OSLC-CoreShapes-3.0-PS01-Pt8",  # fully decomposed
    "OASIS CMIS-v1.1-Errata01",            # errata
    "OASIS OSLC-AM-3.0-Part1-PS01",        # order variant
  ]
end
