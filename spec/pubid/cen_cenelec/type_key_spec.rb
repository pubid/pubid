# frozen_string_literal: true

require "spec_helper"

# CenCenelec.locate_type returns the FIRST identifier class whose type key
# matches, in Identifiers.constants order — and Module#constants has no
# order guarantee. CenelecHarmonizationDocument shared the key :hd with
# HarmonizationDocument, so "HD 123:2020" built either class depending on
# what had loaded before (seen as 6 failures in one spec order only).
#
# Its autoload was also misspelled (CENelecHarmonizationDocument), so the
# class joined identifier_types only when something else had loaded its
# file first. The examples load it and rebuild the memoized list, so they
# do not depend on spec order either.
RSpec.describe "Pubid::CenCenelec type keys" do
  before do
    Pubid::CenCenelec::Identifiers::CenelecHarmonizationDocument
    Pubid::CenCenelec.instance_variable_set(:@identifier_types, nil)
  end

  after { Pubid::CenCenelec.instance_variable_set(:@identifier_types, nil) }

  it "lists the CENELEC HD among the identifier types" do
    expect(Pubid::CenCenelec.identifier_types)
      .to include(Pubid::CenCenelec::Identifiers::CenelecHarmonizationDocument)
  end

  it "gives every identifier type its own key" do
    keys = Pubid::CenCenelec.identifier_types.map { |t| t.type[:key] }
    expect(keys.tally.select { |_, n| n > 1 }).to be_empty
  end

  it "resolves the HD key to HarmonizationDocument" do
    expect(Pubid::CenCenelec.locate_type(:hd))
      .to eq(Pubid::CenCenelec::Identifiers::HarmonizationDocument)
  end

  it "keeps the CENELEC HD printing HD" do
    klass = Pubid::CenCenelec::Identifiers::CenelecHarmonizationDocument
    expect(klass.type[:short]).to eq("HD")
  end
end
