# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # Consolidated Identifier - contains base document plus supplements
      # Example: "BS 4592-0:2006+A1:2012" = [BS 4592-0:2006, Amendment 1:2012]
      class ConsolidatedIdentifier < Base
        attribute :identifiers, Base, polymorphic: true, collection: true

        def to_s(lang: :en, lang_single: false)
          base_id = identifiers.first

          # Render base without suffixes (will add them after supplements)
          result = if base_id.respond_to?(:to_s_without_suffixes)
                     base_id.to_s_without_suffixes
                   else
                     # Temporarily remove suffixes for rendering
                     base_str = base_id.to_s
                     # Remove known suffixes (more flexible patterns to handle topics)
                     base_str = base_str.sub(/ ExComm \(.*?\)$/, "") # ExComm (Fire)
                       .sub(/ ExComm$/, "") # ExComm without topic
                       .sub(/ - TC$/, "")
                       .sub(/ PDF$/, "")
                       .sub(/ \([A-Z][a-z]+\)$/, "")
                     base_str
                   end

          # Add supplements
          identifiers[1..].each do |id|
            if id.is_a?(Amendment)
              if id.amendment_year
                sep = id.respond_to?(:separator) && id.separator ? id.separator : "+"
                result += "#{sep}A#{id.amendment_number}:#{id.amendment_year}"
              else
                # Letter suffixes (AA, AB, etc.) have a space, numeric suffixes don't
                result += if id.amendment_number&.match?(/^[A-Z]+$/)
                            " AMD #{id.amendment_number}"
                          else
                            " AMD#{id.amendment_number}"
                          end
              end
            elsif id.is_a?(Corrigendum)
              sep = id.respond_to?(:separator) && id.separator ? id.separator : "+"
              result += "#{sep}C"
              result += id.corrigendum_number.to_s if id.corrigendum_number
              result += ":#{id.corrigendum_year}" if id.corrigendum_year
            else
              result += id.to_s
            end
          end

          # Add suffixes from base identifier AFTER supplements
          if base_id.respond_to?(:expert_commentary) && base_id.expert_commentary
            if base_id.respond_to?(:expert_commentary_topic) && base_id.expert_commentary_topic
              result += " ExComm (#{base_id.expert_commentary_topic})"
            else
              result += " ExComm"
            end
          end
          result += " - TC" if base_id.respond_to?(:tracked_changes) && base_id.tracked_changes

          # Translation - preserve the "version" or "Translation" suffix if present
          if base_id.respond_to?(:translation_lang) && base_id.translation_lang
            if base_id.respond_to?(:translation_suffix_type) && base_id.translation_suffix_type == "version"
              result += " (#{base_id.translation_lang} version)"
            elsif base_id.respond_to?(:translation_suffix_type) && base_id.translation_suffix_type == "Translation"
              result += " (#{base_id.translation_lang} Translation)"
            else
              result += " (#{base_id.translation_lang})"
            end
          elsif base_id.respond_to?(:translation_upper) && base_id.translation_upper
            if base_id.respond_to?(:translation_suffix_type) && base_id.translation_suffix_type == "Translation"
              result += " (#{base_id.translation_upper} Translation)"
            else
              result += " (#{base_id.translation_upper})"
            end
          end

          # Reaffirmation notation like (R2004)
          if base_id.respond_to?(:reaffirmation_year) && base_id.reaffirmation_year
            result += " (R#{base_id.reaffirmation_year})"
          end

          result
        end

        def to_urn
          base = identifiers&.first
          return nil unless base

          urn = base.to_urn if base.respond_to?(:to_urn)
          return urn unless urn

          # Append supplement info to URN
          identifiers[1..].each do |id|
            if id.is_a?(Amendment)
              urn += ":amd:#{id.amendment_number}"
              urn += ":#{id.amendment_year}" if id.amendment_year
            elsif id.is_a?(Corrigendum)
              urn += ":cor:#{id.corrigendum_number}"
              urn += ":#{id.corrigendum_year}" if id.corrigendum_year
            end
          end
          urn
        end

        # Delegate to first identifier (base document)
        def publisher
          identifiers&.first&.publisher
        end

        def number
          identifiers&.first&.number
        end

        def year
          identifiers&.first&.year if identifiers&.first.respond_to?(:year)
        end

        def date
          identifiers&.first&.date if identifiers&.first.respond_to?(:date)
        end

        def parts
          identifiers&.first&.parts if identifiers&.first.respond_to?(:parts)
        end

        def part
          identifiers&.first&.part if identifiers&.first.respond_to?(:part)
        end

        def type
          identifiers&.first&.type if identifiers&.first.respond_to?(:type)
        end
      end
    end
  end
end
