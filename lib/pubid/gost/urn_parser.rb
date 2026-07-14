# frozen_string_literal: true

module Pubid
  module Gost
    # Parses GOST URNs back into identifiers.
    #
    # UrnGenerator emits:
    #   urn:gost:std:<number>[:<year>]              (interstate)
    #   urn:gost:std:r:<number>[:<year>]            (Russian national)
    #
    # Examples:
    #   urn:gost:std:14946:82           → GOST 14946-82
    #   urn:gost:std:r:34.12:2015       → GOST R 34.12-2015
    class UrnParser < Pubid::UrnParser::Base
      PREFIX = "urn:gost:std:".freeze

      def parse_urn(urn)
        body = strip_namespace(urn)
        parts = split_parts(body)

        if parts.first == "r"
          number = parts[1]
          year = parts[2]
          Identifiers::NationalStandard.new(number: number, year: year)
        else
          number = parts[0]
          year = parts[1]
          Identifiers::InterstateStandard.new(number: number, year: year)
        end
      end

      private

      def strip_namespace(urn)
        unless urn.downcase.start_with?(PREFIX)
          raise Pubid::UrnParser::Errors::ParseError,
                "Invalid GOST URN: #{urn.inspect}"
        end

        urn[PREFIX.length..]
      end

      def split_parts(body)
        parts = body.split(":")
        raise Pubid::UrnParser::Errors::ParseError,
              "GOST URN missing number: #{body.inspect}" if parts.empty?

        parts
      end
    end
  end
end
