# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/amca"
require_relative "../../support/urn_round_trip"

RSpec.describe Pubid::Amca::UrnParser do
  it_behaves_like "flavor URN round-trip", Pubid::Amca, [
    "AMCA 210-08",
    "ANSI/AMCA Standard 220-21",
    "AMCA Standard 803-02 (R2008)",
    "AMCA Publication 211-22 (Rev. 01-23)",
    "AMCA Publication 1011-03 (R2010)",
    "AMCA 99 JW Interp",
    "ANSI/AMCA 204 Interp",
  ]

  # The URN names the type and the keyed parts, so the identifier comes back
  # as the same class with the same attributes.
  {
    "AMCA Publication 211-22 (Rev. 01-23)" =>
      Pubid::Amca::Identifiers::Publication,
    "AMCA 99 JW Interp" => Pubid::Amca::Identifiers::Interpretation,
    "ANSI/AMCA Standard 220-21" => Pubid::Amca::Identifiers::Standard,
  }.each do |ref, klass|
    it "reads #{ref} back as #{klass.name.split('::').last}" do
      original = Pubid::Amca.parse(ref)
      parsed = Pubid.parse(original.to_urn)
      expect(parsed).to be_a(klass)
      expect(parsed).to eq(original)
    end
  end
end
