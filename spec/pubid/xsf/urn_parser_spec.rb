# frozen_string_literal: true

require "spec_helper"
require_relative "../../support/urn_round_trip"

RSpec.describe Pubid::Xsf::UrnParser do
  it_behaves_like "flavor URN round-trip", Pubid::Xsf, [
    "XEP 0001",
    "XEP 0218",
    # The two named documents: the editor README and the template.
    "XEP README",
    "XEP xxxx",
  ]
end
