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
          result = if base_id.is_a?(Base) && base_id.methods.include?(:to_s_without_suffixes)
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
                sep = id.is_a?(Base) && id.separator ? id.separator : "+"
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
              sep = id.is_a?(Base) && id.separator ? id.separator : "+"
              result += "#{sep}C"
              result += id.corrigendum_number.to_s if id.corrigendum_number
              result += ":#{id.corrigendum_year}" if id.corrigendum_year
            else
              result += id.to_s
            end
          end

          # Add suffixes from base identifier AFTER supplements
          if base_id.is_a?(Base)
            ec = begin
              base_id.expert_commentary
            rescue NoMethodError
              nil
            end
            if ec
              ect = begin
                base_id.expert_commentary_topic
              rescue NoMethodError
                nil
              end
              result += ect ? " ExComm (#{ect})" : " ExComm"
            end

            tc = begin
              base_id.tracked_changes
            rescue NoMethodError
              nil
            end
            result += " - TC" if tc

            # Translation - preserve the "version" or "Translation" suffix if present
            tl = begin
              base_id.translation_lang
            rescue NoMethodError
              nil
            end
            if tl
              ts_type = begin
                base_id.translation_suffix_type
              rescue NoMethodError
                nil
              end
              if ts_type == "version"
                result += " (#{tl} version)"
              elsif ts_type == "Translation"
                result += " (#{tl} Translation)"
              else
                result += " (#{tl})"
              end
            else
              tu = begin
                base_id.translation_upper
              rescue NoMethodError
                nil
              end
              if tu
                ts_type = begin
                  base_id.translation_suffix_type
                rescue NoMethodError
                  nil
                end
                if ts_type == "Translation"
                  result += " (#{tu} Translation)"
                else
                  result += " (#{tu})"
                end
              end
            end

            # Reaffirmation notation like (R2004)
            ry = begin
              base_id.reaffirmation_year
            rescue NoMethodError
              nil
            end
            result += " (R#{ry})" if ry
          end

          result
        end

        def to_urn
          base = identifiers&.first
          return nil unless base

          urn = begin
            base.to_urn
          rescue NoMethodError
            nil
          end
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
          base = identifiers&.first
          base.year if base && base.methods.include?(:year)
        end

        def date
          base = identifiers&.first
          base.date if base && base.methods.include?(:date)
        end

        def parts
          base = identifiers&.first
          base.parts if base && base.methods.include?(:parts)
        end

        def part
          base = identifiers&.first
          base.part if base && base.methods.include?(:part)
        end

        def type
          base = identifiers&.first
          base.type if base && base.methods.include?(:type)
        end
      end
    end
  end
end
