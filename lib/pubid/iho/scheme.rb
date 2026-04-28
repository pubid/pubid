# frozen_string_literal: true

module Pubid
  module Iho
    # Scheme registry for IHO identifier types.
    class Scheme < Pubid::Scheme
      IDENTIFIERS = [
        Identifiers::Standard,
        Identifiers::Publication,
        Identifiers::Miscellaneous,
        Identifiers::Bibliographic,
        Identifiers::CircularLetter,
      ].freeze

      def initialize
        @identifiers = IDENTIFIERS
      end

      # Look up an identifier class by its IHO series letter (S/P/M/B/C).
      # @param letter [String]
      # @return [Class<Identifiers::Base>]
      # @raise [KeyError] if the letter is not a known IHO series
      def self.identifier_klass_for_type_letter(letter)
        @by_letter ||= IDENTIFIERS.to_h { |klass| [klass.type[:short], klass] }
        @by_letter.fetch(letter.to_s)
      end
    end
  end
end
