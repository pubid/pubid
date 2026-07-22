# frozen_string_literal: true

module Pubid
  module Easc
    # Base class for all EASC identifiers. Canonical name
    # Pubid::Easc::Identifier; every concrete EASC identifier
    # (Identifiers::*) descends from it.
    #
    # EASC identifiers have the form:
    #   <series> [В ]<number>[-<year>]
    #
    # Where:
    #   * <series> identifies the document class — ПМГ (Правила
    #     межгосударственной стандартизации) or РМГ (Рекомендации по
    #     межгосударственной стандартизации). Latin forms PMG/RMG are
    #     also parsed; canonical render is Cyrillic per mgscatalog.by.
    #   * the optional "В" (Cyrillic capital V) marks a defense-related
    #     variant (e.g. "ПМГ В 31-2001"). Stored as `variant: "V"`
    #     (Latin) for cross-script consistency.
    #   * <number> is a digit run.
    #   * <year> is 2 or 4 digits, separated by ASCII hyphen OR Unicode
    #     em-dash / en-dash (Russian typographic convention).
    #
    # Examples:
    #   ПМГ 03-2025
    #   ПМГ В 31-2001
    #   РМГ 151-2025
    #   РМГ 29-2013
    class Identifier < ::Pubid::Identifier
      def self.parse(identifier)
        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse EASC identifier '#{identifier}': #{e.message}"
      end

      attribute :publisher, :string, default: "EASC"
      attribute :series,  :string    # "PMG" | "RMG" — Latin canonical
      attribute :variant, :string    # "V" | nil
      attribute :number,  :string    # "151", "03", "31"
      attribute :year,    :string    # "2025", "13", nil

      EASC_TYPE_MAP = {
        "pubid:easc:pmg" => "Pubid::Easc::Identifiers::Pmg",
        "pubid:easc:rmg" => "Pubid::Easc::Identifiers::Rmg",
      }.freeze

      key_value do
        map "_type",   to: :_type, polymorphic_map: EASC_TYPE_MAP
        map "series",  to: :series
        map "variant", to: :variant
        map "number",  to: :number
        map "year",    to: :year
      end

      def to_urn
        UrnGenerator.new(self).generate
      end
    end
  end
end
