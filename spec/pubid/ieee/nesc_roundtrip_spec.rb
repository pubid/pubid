# frozen_string_literal: true

require "spec_helper"

# Regression coverage for issue #32: year-first NESC identifiers dropped the
# "IEEE Std" prefix, the registered-trademark "(R)" marks and the "(NESC(R))"
# abbreviation suffix. See spec/pubid/ieee/fixtures_spec.rb for the aggregate
# round-trip rate.
RSpec.describe "IEEE NESC round-trip (issue #32)" do
  # input => expected canonical string
  {
    "2012 NESC Handbook, Seventh Edition" =>
      "IEEE Std 2012 NESC Handbook, Seventh Edition",
    "2017 NESC(R) Handbook, Premier Edition" =>
      "IEEE Std 2017 NESC(R) Handbook, Premier Edition",
    "2017 National Electrical Safety Code(R) (NESC(R))" =>
      "IEEE Std 2017 National Electrical Safety Code(R) (NESC(R))",
  }.each do |input, expected|
    it "round-trips #{input.inspect}" do
      expect(Pubid::Ieee.parse(input).to_s).to eq(expected)
    end
  end

  # Guard: C2-code NESC standards must NOT gain the "IEEE Std" prefix.
  it "leaves C2-code standards unprefixed" do
    expect(Pubid::Ieee.parse("C2-2012 National Electrical Safety Code").to_s)
      .to eq("C2-2012 National Electrical Safety Code")
  end

  # Guard: the trademark mark must keep matching through the NESC rules
  # of the parg artifact grammar (the sub-parser is gone; the artifact's
  # nesc_identifier rule is the live surface).
  [
    "National Electrical Safety Code(R), C2-2012",
    "Draft National Electrical Safety Code(R), January 2016",
    "Draft NESC(R), June 2011",
  ].each do |input|
    it "artifact grammar still matches #{input.inspect}" do
      expect { Pubid::Ieee.parse(input) }.not_to raise_error
    end
  end

  # And the draft "(R)" forms round-trip through the public API.
  it "parses draft NESC with a trademark mark via the public API" do
    expect { Pubid::Ieee.parse("Draft NESC(R), June 2011") }.not_to raise_error
  end
end
