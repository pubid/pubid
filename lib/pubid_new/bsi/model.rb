require "lutaml/model"

module PubidNew
  module Bsi
    # Supplement model for amendments and corrigenda
    class Supplement < Lutaml::Model::Serializable
      attribute :type, :string
      attribute :number, :string
      attribute :year, :string, default: -> {}

      def to_s
        prefix = type == "amendment" ? "A" : "C"
        result = "+#{prefix}#{number}"
        result += ":#{year}" if year
        result
      end
    end

    # National Annex model
    class NationalAnnex < Lutaml::Model::Serializable
      attribute :type, :string
      attribute :supplement, Supplement, default: -> {}
      attribute :base, Identifier, default: -> {}

      def to_s
        result = type
        result += supplement.to_s if supplement
        result += " to #{base}" if base
        result
      end
    end

    # Collection model for combined documents (e.g., PAS 2035/2030)
    class Collection < Lutaml::Model::Serializable
      attribute :type, :string
      attribute :numbers, :string, collection: true
      attribute :year, :string, default: -> {}
      attribute :supplements, Supplement, collection: true, default: -> { [] }

      def to_s
        result = "#{type} #{numbers.join('/')}"
        result += ":#{year}" if year
        supplements.each { |s| result += s.to_s }
        result
      end
    end

    # Expert Commentary model
    class ExpertCommentary < Lutaml::Model::Serializable
      attribute :base, Identifier

      def to_s
        "#{base} ExComm"
      end
    end

    # Main BSI Identifier model
    class Identifier < Lutaml::Model::Serializable
      attribute :type, :string, default: -> { "BS" }
      attribute :number, :string, default: -> {}
      attribute :part, :string, default: -> {}
      attribute :second_number, :string, default: -> {}
      attribute :year, :string, default: -> {}
      attribute :month, :string, default: -> {}
      attribute :edition, :string, default: -> {}
      attribute :supplements, Supplement, collection: true, default: -> { [] }
      attribute :adopted, :string, default: -> {
      } # Will store adopted identifier object
      attribute :expert_commentary, :boolean, default: -> { false }
      attribute :tracked_changes, :boolean, default: -> { false }
      attribute :translation, :string, default: -> {}
      attribute :pdf, :boolean, default: -> { false }
      attribute :national_annex, NationalAnnex, default: -> {}

      def to_s
        # Handle national annex
        if national_annex
          return render_national_annex
        end

        # Handle expert commentary
        if expert_commentary
          base_id = self.class.new(
            type: type,
            number: number,
            part: part,
            year: year,
            month: month,
            supplements: supplements,
            adopted: adopted,
          )
          return "#{base_id} ExComm"
        end

        # Handle collection (combined documents)
        if second_number
          return render_collection
        end

        # Regular identifier
        render_identifier
      end

      private

      def render_national_annex
        result = "NA"

        # Add NA supplements
        if national_annex.supplement
          result += national_annex.supplement.to_s
        end

        result += " to "

        # Render base identifier
        base_id = self.class.new(
          type: type,
          number: number,
          part: part,
          year: year,
          month: month,
          supplements: supplements,
          adopted: adopted,
        )
        result += base_id.to_s

        result
      end

      def render_collection
        first_num = number
        second_num = second_number

        result = "#{type} #{first_num}/#{second_num}"
        result += ":#{year}" if year
        supplements.each { |s| result += s.to_s }

        result
      end

      def render_identifier
        ""

        # Type prefix
        result = if type == "BSI Flex"
                   "BSI Flex"
                 else
                   type
                 end

        result += " "

        # Adopted document or number
        if adopted
          # For adopted documents, render the adopted identifier
          # but suppress its year if we have our own year
          adopted_str = adopted.to_s
          if year && adopted.respond_to?(:year)
            # Remove year from adopted if we have our own
            adopted_str = adopted_str.sub(/:#{adopted.year}/, "")
          end
          result += adopted_str
        else
          # Regular number
          result += number.to_s if number
          result += "-#{part}" if part
        end

        # Edition (for Flex) - must come before year-month
        result += " v#{edition}" if edition

        # Year and month
        if year
          result += ":#{year}"
          result += "-#{month}" if month
        end

        # Supplements
        supplements.each { |s| result += s.to_s }

        # Tracked changes
        result += " - TC" if tracked_changes

        # Translation
        result += " (#{translation})" if translation

        # PDF marker
        result += " PDF" if pdf

        result
      end
    end
  end
end
