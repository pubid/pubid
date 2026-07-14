# frozen_string_literal: true

module Pubid
  module Easc
    # Parses EASC URNs back into identifiers.
    #
    # UrnGenerator emits:
    #   urn:easc:<series>[:<variant>]:<number>[:<year>]
    #
    # Examples:
    #   urn:easc:pmg:3:2025           → ПМГ 3-2025
    #   urn:easc:pmg:v:31:2001        → ПМГ В 31-2001
    #   urn:easc:rmg:151:2025         → РМГ 151-2025
    class UrnParser < Pubid::UrnParser::Base
      PREFIX = "urn:easc:".freeze
      VARIANT_SEGMENT = /\Av\z/i.freeze

      def parse_urn(urn)
        body = strip_namespace(urn)
        parts = split_parts(body)
        series = parts.fetch(0)
        rest = parts.drop(1)

        variant = nil
        if rest.first&.match?(VARIANT_SEGMENT)
          variant = "V"
          rest = rest.drop(1)
        end
        number = rest[0]
        year = rest[1]

        klass = Easc.identifier_klass_for_series(series) || Identifiers::Base
        klass.new(series: series.upcase, variant: variant,
                  number: number, year: year)
      end

      private

      def strip_namespace(urn)
        unless urn.downcase.start_with?(PREFIX)
          raise Pubid::UrnParser::Errors::ParseError,
                "Invalid EASC URN: #{urn.inspect}"
        end

        urn[PREFIX.length..]
      end

      def split_parts(body)
        parts = body.split(":")
        raise Pubid::UrnParser::Errors::ParseError,
              "EASC URN missing series: #{body.inspect}" if parts.empty?

        parts
      end
    end
  end
end
