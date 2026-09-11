# frozen_string_literal: true

module Pubid
  module CenCenelec
    # The second of CEN/CENELEC's two identifier roots (the other is
    # Identifiers::Base); both descend from Pubid::CenCenelec::Identifier so every
    # concrete type is `is_a?` it.
    class SingleIdentifier < Pubid::CenCenelec::Identifier
      attribute :publisher, Components::Publisher, default: -> {
        self.class.default_publisher
      }

      # Generate URN for this identifier
      #
      # @return [String] URN representation

      def self.type
        nil
      end

      # The `publisher` default: the type token for a publisher-type
      # ("CWA 14050", "HD 1215", "CR 954", "ES 59008", "ENV 1613"), else EN.
      # `to_hash` leaves out a value equal to its default, so the publisher
      # of those five is not written: `_type` already names it.
      def self.default_publisher
        short = type.is_a?(Hash) ? type[:short] : nil
        body = CenCenelec::PUBLISHER_TYPES.include?(short) ? short : "EN"
        Components::Publisher.new(body: body)
      end

      # The `type` default of a typed leaf. It is a Components::Type, like
      # the value the parser sets for "CEN/TR", so a document with no type
      # token deserializes the same way it parses. The default used to be the
      # bare Symbol `type[:key]`, and from_hash raised on it.
      def self.default_type
        Components::Type.new(abbr: type[:short])
      end

      def to_s(lang: :en, lang_single: false, **opts)
        render(format: :human, lang: lang, lang_single: lang_single, **opts)
      end

      def <=>(other)
        return nil unless other.is_a?(SingleIdentifier)

        # Compare by number first
        num_cmp = number.to_s <=> other.number.to_s
        return num_cmp unless num_cmp.zero?

        # Then by part
        part_cmp = (part || "0").to_s <=> (other.part || "0").to_s
        return part_cmp unless part_cmp.zero?

        # Then by date
        if date && other.date
          date.to_s <=> other.date.to_s
        elsif date
          1
        elsif other.date
          -1
        else
          0
        end
      end
    end
  end
end
