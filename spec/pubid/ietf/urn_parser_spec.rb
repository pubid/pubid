# frozen_string_literal: true

require "spec_helper"
require_relative "../../support/urn_round_trip"

RSpec.describe Pubid::Ietf::UrnParser do
  it_behaves_like "flavor URN round-trip", Pubid::Ietf, [
    "RFC 2119",
    "BCP 3",
    "STD 66",
    "FYI 1",
    "draft-giuliano-treedn-02",
    "draft-giuliano-treedn",
    "draft-adams-cast-256",
  ]

  it "rejects a URN with an unknown type token" do
    expect { described_class.parse("urn:ietf:bogus:1") }
      .to raise_error(StandardError)
  end
end
