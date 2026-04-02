
# frozen_string_literal: true

module Pubid
  module Ccsds
    class SingleIdentifier < Identifier
      attribute :publisher, Components::Publisher, default: -> {
        Components::Publisher.new(body: "CCSDS")
      }
      attribute :series, Components::Code
      attribute :number, Components::Code
      attribute :part, Components::Code
      attribute :book_color, Components::Code
      attribute :edition, Components::Edition
      attribute :retired, :boolean, default: -> { false }
      attribute :language, Components::Language
      attribute :type, Components::Type
      attribute :typed_stage, Components::TypedStage

      def to_s(lang: :en, lang_single: false)
        result = ""

        # Publisher
        result += publisher.body if publisher

        # Space after publisher
        result += " "

        # Series (optional single letter before number)
        result += series.value if series

        # Number with part (using dot notation)
        result += number.value
        result += ".#{part.value}" if part

        # Book color (required) - no space before dash
        result += "-#{book_color.value}" if book_color

        # Edition (optional)
        result += "-#{edition.number}" if edition

        # Retired marker (optional)
        result += "-S" if retired

        # Language (optional)
        result += " - #{language.code} Translated" if language

        result
      end

      def <=>(other)
        return nil unless other.is_a?(SingleIdentifier)

        # Compare by number first
        num_cmp = number.value.to_i <=> other.number.value.to_i
        return num_cmp unless num_cmp.zero?

        # Then by part
        part_cmp = (part ? part.value.to_i : 0) <=> (other.part ? other.part.value.to_i : 0)
        return part_cmp unless part_cmp.zero?

        # Then by edition
        if edition && other.edition
          edition.number.to_s <=> other.edition.number.to_s
        elsif edition
          1
        elsif other.edition
          -1
        else
          0
        end
      end
    end
  end
end
