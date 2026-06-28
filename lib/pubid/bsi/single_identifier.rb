# frozen_string_literal: true

module Pubid
  module Bsi
    # BSI base class. Canonical name Pubid::Bsi::Identifier; SingleIdentifier is a
    # back-compat alias (BSI's common ancestor — there is no Identifiers::Base).
    # Every concrete BSI identifier descends from it, so they are all
    # `is_a?(Pubid::Bsi::Identifier)` natively and get the shared polymorphic
    # `from_hash` (no facade needed).
    class Identifier < ::Pubid::Identifier
      def self.parse(string)
        if string.length > Pubid::MAX_INPUT_LENGTH
          raise ArgumentError, Pubid::INPUT_TOO_LONG_MESSAGE
        end

        # Delegate to IEC for bare IEC identifiers. This handles IEC-specific
        # features like VAP suffixes (CSV, RLV, etc.) and consolidated
        # supplements (+AMD1:2001).
        if string.match?(/\bIEC\b/) &&
            (string.match?(/\s+(CSV|CMV|RLV|SER|EXV|PAC|PRV)\b/) ||
             string.match?(/\+AMD\d+:/) ||
             string.match?(/\+COR\d+:/))
          return Pubid::Iec.parse(string)
        end

        parser = Parser.new

        parsed = parser.parse(string)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise StandardError, "Failed to parse '#{string}': #{e.message}"
      end

      attribute :publisher, Bsi::Components::Publisher, default: -> {
        Bsi::Components::Publisher.new(body: "BS")
      }
      attribute :prefix, :string # Specialized prefix (A, AU, C, M, 2A, etc.)
      attribute :flex_prefix, :string # Flex type prefix (CECC, E9111, M, etc.)
      attribute :number, Bsi::Components::Code
      attribute :iteration, :string # For bracket notation like 1000[9]
      attribute :part, Bsi::Components::Code
      attribute :subpart, Bsi::Components::Code
      attribute :second_number, Bsi::Components::Code # For collections like PAS 2035/2030
      attribute :date, Bsi::Components::Date
      attribute :stage, Pubid::Components::Stage
      attribute :type, Bsi::Components::Type
      attribute :typed_stage, Pubid::Components::TypedStage
      attribute :edition, :string
      attribute :month, :integer
      attribute :translation_lang, :string
      attribute :translation_upper, :string
      attribute :explicit_prefix, :boolean, default: -> { false }
      attribute :explicit_publisher, :boolean, default: -> { false }
      attribute :space_separated_part, :boolean, default: -> { false }

      def <=>(other)
        return nil unless other.is_a?(Pubid::Bsi::Identifier)

        # Compare by number first
        num_cmp = number.to_s <=> other.number.to_s
        return num_cmp unless num_cmp.zero?

        # Then by part
        part_cmp = (part || Components::Code.new(value: "0")).to_s <=> (other.part || Components::Code.new(value: "0")).to_s
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

    # Backward-compatible alias: BSI's base class is Pubid::Bsi::Identifier.
    # Concrete types declared as `< SingleIdentifier` continue to work.
    SingleIdentifier = Identifier
  end
end
