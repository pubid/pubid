# frozen_string_literal: true

module Pubid
  module Bsi
    class SingleIdentifier < Pubid::Identifier
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
        # Build string representation
        parts = []

        # For supplement/addendum base identifiers, flex_prefix replaces publisher+prefix
        parts << publisher.to_s if publisher
        if flex_prefix
          # Flex prefix is the full prefix including BS (e.g., "BS CECC" becomes "BS" + space + "CECC")
          parts << flex_prefix
        elsif prefix
          # Standard publisher

          # Prefix if present (specialized prefix like A, AU, C, etc.)
          parts << prefix.to_s
        end

        # Number with iteration, part, and subpart
        if number
          number_str = number.is_a?(Components::Code) ? number.value.to_s : number.to_s

          # Collection (second number with slash)
          if second_number
            second_val = second_number.is_a?(Components::Code) ? second_number.value : second_number
            number_str += "/#{second_val}"
          end

          # Part and subpart - check if space-separated
          space_separated = space_separated_part
          if part
            part_val = part.is_a?(Components::Code) ? part.value : part
            # Trim part value to remove leading/trailing spaces from parser
            part_str = part_val.to_s.strip
            # Use space for space-separated parts, dash otherwise
            separator = space_separated ? " " : "-"
            number_str += "#{separator}#{part_str}"
          end
          if subpart
            subpart_val = subpart.is_a?(Components::Code) ? subpart.value : subpart
            subpart_str = subpart_val.to_s.strip
            number_str += "-#{subpart_str}"
          end

          # Iteration (bracket notation like 1000[9])
          if iteration && !iteration.empty?
            number_str += "[#{iteration}]"
          end

          parts << number_str
        end

        result = parts.join(" ")

        # Date
        if date
          year_val = date.is_a?(Components::Date) ? date.year : date.to_i
          result += ":#{year_val}"
          # Month if present
          result += "-#{format('%02d', month)}" if month
        end

        # Edition
        result += " v#{edition}" if edition

        # Translation
        if translation_lang
          result += " (#{translation_lang})"
        elsif translation_upper
          result += " (#{translation_upper})"
        end

        result
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
