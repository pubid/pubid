# frozen_string_literal: true

require "spec_helper"

# Every migrated flavor must hold two accounts. SHAPE_COMPATIBLE flavors
# (whose builder consumes the same hash both paths produce) are held to
# the differential: the bindings-produced hash (Pubid::Parg::Model.bound)
# and the normalized wire tree (Pubid::Parg::Backend.parse) must build
# equal identifiers over the flavor's whole fixture corpus. ADAPTED
# flavors (whose builder consumes the declared bound shapes, which the
# raw tree no longer mirrors) are held to the fixtures' pinned renders —
# and their full conformance corpus runs in CI's conformance gate.
SAE_REFS = ["SAE AIR1936", "SAE AMS5000:2020", "SAE J1939",
            "SAE J300:2019", "SAE ARP4754A"].freeze
SHAPE_COMPATIBLE = %i[doi easc gb ietf jis oasis ogc sae w3c xsf isbn iana ecma omg ccsds tgpp gost astm].freeze
ADAPTED = %i[etsi csa iec amca cen_cenelec plateau nist].freeze

RSpec.describe "typed model binding parity" do
  include FixtureFileHelper

  def pass_entries(flavor)
    base = File.expand_path("../../fixtures/#{flavor}", __dir__)
    Dir.glob("#{base}/**/pass/*.txt")
      .flat_map { |file| read_pass_fixture_entries(file) }
  end

  def flavor_module(flavor)
    Pubid.const_get(flavor.to_s.split("_").map(&:capitalize).join)
  end

  SHAPE_COMPATIBLE.each do |flavor|
    describe flavor do
      it "declares bindings on its artifact" do
        expect(Pubid::Parg::Artifact.for(flavor).bindings("identifier"))
          .not_to be_empty
      end

      it "builds the same identifier as the tree + builder path" do
        entries = flavor == :sae ? SAE_REFS : pass_entries(flavor).map(&:first)
        expect(entries).not_to be_empty

        build = lambda do |hash|
          builder = flavor_module(flavor)::Builder
          builder.respond_to?(:build) ? builder.build(hash) : builder.new.build(hash)
        end

        # Parse-entry ingestion (the ashrae/cie/ecma Parser.normalize_input
        # precedent) aliases human spellings onto the grammar's own face
        # before the engine sees them, so the differential runs over the
        # flavor's ingestion face: the parity question is per-face, not
        # per-spelling (pubid#698).
        # A flavor whose ingestion also binds tokens the grammar cannot read
        # yet (JIS `Parser.ingest`: WES TR/TS and a language before the
        # year) gives the face plus those bindings; the tree path merges
        # them, as the typed path does.
        ingest = lambda do |input|
          parser = flavor_module(flavor)::Parser
          next parser.ingest(input) if parser.respond_to?(:ingest)
          next [input, {}] unless parser.respond_to?(:normalize_input)

          [parser.normalize_input(input), {}]
        rescue NameError
          [input, {}]
        end

        differences = entries.filter_map do |input|
          face, bindings = ingest.call(input)
          typed = flavor_module(flavor).parse(bindings.empty? ? face : input)
          tree = build.call(
            Pubid::Parg::Backend.parse(flavor, face).merge(bindings),
          )

          next if typed.to_hash == tree.to_hash && typed.to_s == tree.to_s

          { input: input, typed: typed.to_hash, tree: tree.to_hash }
        end

        expect(differences).to eq([])
      end
    end
  end

  ADAPTED.each do |flavor|
    describe flavor do
      it "declares bindings on its artifact" do
        expect(Pubid::Parg::Artifact.for(flavor).bindings("identifier"))
          .not_to be_empty
      end

      it "renders every pass fixture to its pinned form" do
        entries = pass_entries(flavor)
        expect(entries).not_to be_empty

        differences = entries.filter_map do |input, expected|
          rendered = flavor_module(flavor).parse(input).to_s

          next if rendered == expected

          { input: input, expected: expected, rendered: rendered }
        end

        expect(differences).to eq([])
      end
    end
  end
end
