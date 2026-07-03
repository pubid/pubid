# frozen_string_literal: true

module Pubid
  module CenCenelec
    # Common base class for all CEN/CENELEC identifiers. CEN/CENELEC has a split
    # hierarchy — some concrete types descend from Identifiers::Base, others from
    # SingleIdentifier — so this class is the shared parent of BOTH, making every
    # CEN/CENELEC identifier `is_a?(Pubid::CenCenelec::Identifier)` natively (and
    # giving them the shared polymorphic `from_hash`). No facade needed.
    class Identifier < ::Pubid::Identifier
      def self.parse(identifier)
        if identifier.length > Pubid::MAX_INPUT_LENGTH
          raise ArgumentError, Pubid::INPUT_TOO_LONG_MESSAGE
        end

        parsed = Parser.parse(identifier)
        Builder.new.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse CEN identifier '#{identifier}': #{e.message}"
      end
    end
  end
end
