# frozen_string_literal: true

require "spec_helper"
require_relative "../pubid_urn_contract_spec"

# The slug form (relaton#441): the pubid-scheme URN in HTTP-path
# clothes. The transform is bijective — the contract's path-safety gate
# guarantees no segment carries a "/", so from_slug rebuilds the exact
# URN and every landed flavor's slug round-trips by to_hash.
RSpec.describe "PubidUrn slug" do
  before { Pubid.parse("ISO 1234") rescue nil }

  describe "the transform" do
    it "cuts the prefix and joins the segments with /" do
      id = Pubid::Registry.get("iso").parse("ISO 4064-1:2024")
      expect(Pubid.to_slug(id)).to eq("iso/is/4064/part-1/year-2024")
    end

    it "accepts a URN string as well as an identifier" do
      id = Pubid::Registry.get("iso").parse("ISO 4064-1:2024")
      expect(Pubid.to_slug(id.to_pubid_urn)).to eq(Pubid.to_slug(id))
    end

    it "carries the facet group as its own segments" do
      id = Pubid::Registry.get("oiml").parse("OIML D 2 (E)")
      expect(Pubid.to_slug(id)).to include("/f/")
    end

    it "refuses empty segments" do
      expect { Pubid.from_slug("iso//is") }
        .to raise_error(Pubid::Errors::UrnParseError, /empty segments/)
    end

    it "refuses a non-String" do
      expect { Pubid.from_slug(nil) }
        .to raise_error(Pubid::Errors::InvalidInputError)
    end
  end

  describe "round-trip over the landed flavors" do
    include PubidUrnContract

    landed = Pubid::Registry.flavor_names.sort
                  .group_by { |n| Pubid::Registry.get(n) }.values
                  .map { |names| names.max_by(&:length) }
                  .reject { |name| PubidUrnContract::PENDING.include?(name) }

    landed.each do |flavor|
      it "#{flavor}: every pass fixture's slug rebuilds the identifier" do
        mod = Pubid::Registry.get(flavor)
        PubidUrnContract.inputs(flavor).each do |input|
          id = mod.parse(input)
          slug = Pubid.to_slug(id)
          expect(slug).not_to include(":")

          back = Pubid.from_slug(slug)
          expect(back.to_hash).to eq(id.to_hash)
          expect(Pubid.to_slug(back)).to eq(slug)
        end
      end
    end
  end
end
