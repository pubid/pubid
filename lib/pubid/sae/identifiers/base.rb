# frozen_string_literal: true

module Pubid
  module Sae
    # Base SAE Identifier. Canonical name Pubid::Sae::Identifier. SAE has a single identifier class that IS the
    # document type, so this class is both the base and the only concrete type.
    # Handles every SAE document family (Components::Type::TYPES).
    class Identifier < ::Pubid::Identifier
      def self.parse(input)
        unless input.is_a?(String)
          raise Pubid::Errors::InvalidInputError,
                Pubid::INPUT_NOT_A_STRING_MESSAGE
        end

        if input.length > Pubid::MAX_INPUT_LENGTH
          raise Pubid::Errors::InvalidInputError, Pubid::INPUT_TOO_LONG_MESSAGE
        end

        input = ::Pubid.utf8_input(input)

        parsed = Pubid::Parg::Model.bound(:sae, input)
        Builder.build(parsed)
      end

      attribute :publisher, :string, default: -> { "SAE" }
      attribute :type, Sae::Components::Type
      # A plain :string, like every converted flavor. Sae::Components::Code was
      # a bare alias of the shared component and never carried more than
      # `value`, so this is a representation change only.
      attribute :number, :string
      # The revision letter (AMS4121J -> "J"), or USCAR's revision number
      # (USCAR2-6 -> "6"). Kept out of `number`, so every revision of a
      # document shares one index bucket and a reference without a revision
      # matches them all under `===`.
      attribute :revision, :string
      # The amendment of a revision: AS5259/7A_A1 -> "1".
      attribute :amendment, :string
      attribute :date, Sae::Components::Date

      # A part (J2337/2) and an amendment (_A1) are other documents: a
      # reference without one names the document that has none.
      subset_strict :part, :amendment

      def self.type
        { key: :base, web: :standard, title: "Standard", short: "SAE" }
      end

      def year
        date&.year
      end

      # SAE encodes the document class (AS, ARP, AMS, AIR, J, …) in `type.abbr`,
      # not in `typed_stage.type_code`, so the generic mr_type returns nil.
      # Losslessness requires the type letter to appear in MR — without it,
      # `SAE J300` and `SAE AS300` would collide on `SAE.300.<year>`.
      # Lowercased to match the all-lowercase MR convention (issue #142).
      def mr_type
        type&.abbr&.to_s&.downcase
      end

      # The code after the type and its separator, without the date:
      # "4121J", "22520/45A", "5259/7A_A1", "2-6" (USCAR-2 Revision 6).
      # The renderer prints it after the type; the URN carries it as one
      # segment.
      def designation
        dash = dash_revision?
        code = number.to_s
        code += "-#{revision}" if revision && dash
        code += "/#{part}" if part
        code += revision.to_s if revision && !dash
        code += "_A#{amendment}" if amendment
        code
      end

      # A revision after a part (AS22520/45A) is the part document's
      # revision, so dropping the part drops it too. Without this,
      # `exclude(:part)` would turn it into revision A of the base document
      # (AS22520A) and `matches?(other, ignore: [:part])` would pair the two.
      def exclude(*args)
        args += [:revision] if part && args.include?(:part)
        super
      end

      # A numbered revision of a USCAR family (USCAR-2-6). A letter revision
      # (USCAR3A) prints glued, as in every other family.
      def dash_revision?
        Sae::Components::Type::DASH_REVISION.include?(type&.abbr.to_s) &&
          revision.to_s.match?(/\A\d+\z/)
      end

      # Each segment carries a letter, so a dash number (J1939-71 ->
      # "1939-71") never collides with a part (J1939/71 -> "1939-p71").
      def mr_number_with_part
        return nil unless number

        segments = [number]
        segments << "p#{part}" if part
        segments << "r#{revision}" if revision
        segments << "a#{amendment}" if amendment
        segments.join("-").downcase
      end
    end

  end
end
