# frozen_string_literal: true

module Pubid
  module Gost
    # Base class for all GOST identifiers.
    #
    # GOST identifiers observed in the wild have the shape:
    #
    #   GOST [R ][<copublisher> ][<subtype> ]<number>[-<year>][/<adopted>][(<refs>)]
    #
    # Where /<adopted> is the IDT slash form (modeled by IdenticalAdoption)
    # and (<refs>) is the parenthesized harmonization list (modeled by
    # Harmonized). A bare InterstateStandard/NationalStandard has neither.
    class Identifier < ::Pubid::Identifier
      def self.parse(identifier)
        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse GOST identifier '#{identifier}': #{e.message}"
      end

      attribute :publisher,   :string, default: "GOST"
      attribute :copublisher, :string
      attribute :subtype,     :string
      attribute :number,      :string
      attribute :year,        :string

      GOST_TYPE_MAP = {
        "pubid:gost:interstate-standard" => "Pubid::Gost::Identifiers::InterstateStandard",
        "pubid:gost:national-standard"   => "Pubid::Gost::Identifiers::NationalStandard",
        "pubid:gost:identical-adoption"  => "Pubid::Gost::Identifiers::IdenticalAdoption",
        "pubid:gost:harmonized"          => "Pubid::Gost::Identifiers::Harmonized",
        "pubid:gost:foreign-reference"   => "Pubid::Gost::Identifiers::ForeignReference",
      }.freeze

      key_value do
        map "_type",       to: :_type, polymorphic_map: GOST_TYPE_MAP
        map "copublisher", to: :copublisher
        map "subtype",     to: :subtype
        map "number",      to: :number
        map "year",        to: :year
      end

      def to_urn
        UrnGenerator.new(self).generate
      end
    end
  end
end
