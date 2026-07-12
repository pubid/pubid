# frozen_string_literal: true

module Pubid
  module Gost
    # Base class for all GOST identifiers. Canonical name
    # Pubid::Gost::Identifier; every concrete GOST identifier
    # (Identifiers::*) descends from it, and Identifiers::Base — aliased
    # at the foot of identifiers/base.rb — points back to it.
    #
    # GOST identifiers have the form:
    #   GOST [R ]<number>[-<year>]
    #
    # Where:
    #   * the optional "R" marks a Russian national standard
    #     (e.g. "GOST R 34.12-2015"); bare "GOST" is interstate.
    #   * <number> is a digit run, optionally dotted ("34.12", "8.595").
    #   * <year> is 2 or 4 digits ("82", "2015").
    #
    # Examples:
    #   GOST 14946-82
    #   GOST R 34.12-2015
    #   ГОСТ Р 34.11-94
    class Identifier < ::Pubid::Identifier
      def self.parse(identifier)
        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse GOST identifier '#{identifier}': #{e.message}"
      end

      attribute :publisher, :string, default: "GOST"
      attribute :scope,  :string    # "russian" | "interstate" | nil
      attribute :number, :string    # "14946", "34.12", "8.595"
      attribute :year,   :string    # "82", "2015", nil

      GOST_TYPE_MAP = {
        "pubid:gost:standard" => "Pubid::Gost::Identifiers::Standard",
      }.freeze

      key_value do
        map "_type",  to: :_type, polymorphic_map: GOST_TYPE_MAP
        map "scope",  to: :scope
        map "number", to: :number
        map "year",   to: :year
      end

      def to_urn
        UrnGenerator.new(self).generate
      end
    end
  end
end
