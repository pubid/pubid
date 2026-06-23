# frozen_string_literal: true

module Pubid
  module Bsi
    class SingleIdentifier < Pubid::Identifier
      # Identity for the Pubid::Bsi::Identifier facade: SingleIdentifier is the
      # common ancestor of every concrete BSI identifier, so including the
      # facade module here makes them all `is_a?(Pubid::Bsi::Identifier)`.
      include Pubid::Bsi::Identifier

      # Generate URN for this identifier
      #
      # @return [String] URN representation

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

      def to_s(lang: :en, lang_single: false)
        render(format: :human, lang: lang, lang_single: lang_single)
      end

      def <=>(other)
        return nil unless other.is_a?(SingleIdentifier)

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
  end
end
