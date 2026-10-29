# frozen_string_literal: true

require "spec_helper"

# Every flavor migrated to typed model bindings holds both paths to the
# same account: the bindings-produced hash (Pubid::Parg::Model.bound) and
# the normalized wire tree (Pubid::Parg::Backend.parse) must build equal
# identifiers over the flavor's whole fixture corpus. The tree path stays
# as the oracle until the last flavor migrates.
SAE_REFS = ["SAE AIR1936", "SAE AMS5000:2020", "SAE J1939",
            "SAE J300:2019", "SAE ARP4754A"].freeze
FLAVORS = %i[doi easc gb ietf jis oasis ogc sae w3c xsf].freeze

RSpec.describe "typed model binding parity" do
  include FixtureFileHelper

  def pass_entries(flavor)
    base = File.expand_path("../../fixtures/#{flavor}", __dir__)
    Dir.glob("#{base}/**/pass/*.txt")
      .flat_map { |file| read_pass_fixture_entries(file) }
  end

  FLAVORS.each do |flavor|
    describe flavor do
      let(:flavor_module) do
        Pubid.const_get(flavor.to_s.split("_").map(&:capitalize).join)
      end

      it "declares bindings on its artifact" do
        expect(Pubid::Parg::Artifact.for(flavor).bindings("identifier"))
          .not_to be_empty
      end

      it "builds the same identifier as the tree + builder path" do
        entries = flavor == :sae ? SAE_REFS : pass_entries(flavor).map(&:first)
        expect(entries).not_to be_empty

        differences = entries.filter_map do |input|
          typed = flavor_module.parse(input)
          tree = flavor_module::Builder.build(
            Pubid::Parg::Backend.parse(flavor, input),
          )

          next if typed.to_hash == tree.to_hash && typed.to_s == tree.to_s

          { input: input, typed: typed.to_hash, tree: tree.to_hash }
        end

        expect(differences).to eq([])
      end
    end
  end
end
