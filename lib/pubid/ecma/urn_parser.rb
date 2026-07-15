# frozen_string_literal: true

module Pubid
  module Ecma
    # Parses ECMA URNs back into identifiers, inverting {UrnGenerator}.
    #
    # Examples:
    #   urn:ecma:411        -> ECMA-411
    #   urn:ecma:418:part-1 -> ECMA-418-1
    #   urn:ecma:tr:101     -> ECMA TR/101
    #   urn:ecma:mem:1970   -> ECMA MEM/1970
    class UrnParser < Pubid::UrnParser::Base
      def parse_urn(urn)
        parts = split_parts(strip_namespace(urn))
        tag = %w[tr mem].include?(parts.first) ? parts.shift : nil
        number = parts.shift
        part = if parts.first&.start_with?("part-")
                 parts.shift.sub("part-", "")
               end
        flavor_parse(reconstruct(tag, number, part))
      end

      private

      # Rebuild the printed identifier string from the URN fields.
      def reconstruct(tag, number, part)
        case tag
        when "tr" then "ECMA TR/#{number}"
        when "mem" then "ECMA MEM/#{number}"
        else part ? "ECMA-#{number}-#{part}" : "ECMA-#{number}"
        end
      end
    end
  end
end
