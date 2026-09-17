# frozen_string_literal: true

module Pubid
  module Ccsds
    # Qualified as ::Pubid::Identifier to avoid resolving to the local
    # Pubid::Ccsds::Identifier module, which is a parser entry point
    # (`self.parse`) — not the base class.
    class SingleIdentifier < ::Pubid::Identifier
      attribute :publisher, Components::Publisher, default: -> {
        Components::Publisher.new(body: "CCSDS")
      }
      # Plain :string, like the live Pubid::Ccsds::Identifier hierarchy, which
      # already declared these as strings. This class is otherwise
      # unreferenced — nothing inherits it and no builder instantiates it — but
      # it is public API, so it is retyped rather than deleted.
      attribute :series, :string
      attribute :number, :string
      attribute :part, :string
      attribute :book_color, :string
      attribute :edition, Components::Edition
      attribute :retired, :boolean, default: -> { false }
      attribute :language, Components::Language
      attribute :type, Components::Type
      attribute :typed_stage, Components::TypedStage

      def to_s(lang: :en, lang_single: false, **opts)
        result = ""

        # Publisher
        result += publisher.body if publisher

        # Space after publisher
        result += " "

        # Series (optional single letter before number)
        result += series.to_s if series

        # Number with part (using dot notation)
        result += number.to_s
        result += ".#{part}" if part

        # Book color (required) - no space before dash
        result += "-#{book_color}" if book_color

        # Edition (optional)
        result += "-#{edition.number}" if edition

        # Retired marker (optional)
        result += "-S" if retired

        # Language (optional)
        result += " - #{language.code} Translated" if language

        annotate_plain_render(result, **opts)
      end

      def <=>(other)
        return nil unless other.is_a?(SingleIdentifier)

        # Compare by number first
        num_cmp = number.to_i <=> other.number.to_i
        return num_cmp unless num_cmp.zero?

        # Then by part
        part_cmp = part.to_i <=> other.part.to_i
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
