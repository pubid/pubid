# frozen_string_literal: true

module Pubid
  module Doi
    class Identifier < ::Pubid::Identifier
      # The DOI prefix: "10." + registrar code, e.g. "10.1000", "10.6028".
      attribute :prefix, :string

      # The DOI suffix: arbitrary printable string with no whitespace. May
      # contain slashes (e.g. "NIST.2022-04-15.001").
      attribute :suffix, :string

      DOI_TYPE_MAP = {
        "pubid:doi:resource" => "Pubid::Doi::Identifiers::Resource",
      }.freeze

      key_value do
        map "_type", to: :_type, polymorphic_map: DOI_TYPE_MAP
        map "prefix", to: :prefix
        map "suffix", to: :suffix
      end

      PUBLISHER = "DOI"

      # The numeric registrar subcode (e.g. "1000" for prefix "10.1000").
      def registrar
        prefix.to_s.sub(/\A10\./, "") unless prefix.to_s.empty?
      end

      def to_s(**opts)
        render(format: :human, **opts)
      end

      def self.parse(identifier)
        unless identifier.is_a?(String)
          raise ArgumentError, Pubid::INPUT_NOT_A_STRING_MESSAGE
        end

        if identifier.length > Pubid::MAX_INPUT_LENGTH
          raise ArgumentError, Pubid::INPUT_TOO_LONG_MESSAGE
        end

        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      end
    end
  end
end
