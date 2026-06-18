# frozen_string_literal: true

# Shared round-trip examples for flavor URN parsers.
#
# Usage:
#   require_relative "support/urn_round_trip"
#
#   RSpec.describe "SAE URN round-trip" do
#     include_examples "URN round-trip", Pubid::Sae, [
#       "SAE J300:2019",
#       "SAE AIR500",
#     ]
#   end
RSpec.shared_examples "flavor URN round-trip" do |flavor_module, identifiers|
  identifiers.each do |text|
    it "round-trips #{text.inspect} via URN (#{flavor_module.name})" do
      original = flavor_module.parse(text)
      urn = original.to_urn
      parsed = Pubid.parse(urn)
      expect(parsed.to_urn).to eq(urn)
    end
  end
end
