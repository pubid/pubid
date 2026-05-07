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
          result = if base_id.is_a?(Base) && base_id.class.method_defined?(:to_s_without_suffixes)
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
            base_attrs = base_id.class.attributes
            ec = base_attrs.key?(:expert_commentary) ? base_id.expert_commentary : nil
            if ec
              ect = base_attrs.key?(:expert_commentary_topic) ? base_id.expert_commentary_topic : nil
              result += ect ? " ExComm (#{ect})" : " ExComm"
            end

            tc = base_attrs.key?(:tracked_changes) ? base_id.tracked_changes : nil
            result += " - TC" if tc

            # Translation - preserve the "version" or "Translation" suffix if present
            tl = base_attrs.key?(:translation_lang) ? base_id.translation_lang : nil
            if tl
              ts_type = base_attrs.key?(:translation_suffix_type) ? base_id.translation_suffix_type : nil
              result += if ts_type == "version"
                          " (#{tl} version)"
                        elsif ts_type == "Translation"
                          " (#{tl} Translation)"
                        else
                          " (#{tl})"
                        end
            else
              tu = base_attrs.key?(:translation_upper) ? base_id.translation_upper : nil
              if tu
                ts_type = base_attrs.key?(:translation_suffix_type) ? base_id.translation_suffix_type : nil
                result += if ts_type == "Translation"
                            " (#{tu} Translation)"
                          else
                            " (#{tu})"
                          end
              end
            end

            # Reaffirmation notation like (R2004)
            ry = base_attrs.key?(:reaffirmation_year) ? base_id.reaffirmation_year : nil
            result += " (R#{ry})" if ry
          end

          result
        end

        def to_urn
          base = identifiers&.first
          return nil unless base

          urn = base.to_urn if base.class.method_defined?(:to_urn)
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
          base.year if base&.class&.attributes&.key?(:year)
        end

        def date
          base = identifiers&.first
          base.date if base&.class&.attributes&.key?(:date)
        end

        def parts
          base = identifiers&.first
          base.parts if base&.class&.attributes&.key?(:parts)
        end

        def part
          base = identifiers&.first
          base.part if base&.class&.attributes&.key?(:part)
        end

        def type
          base = identifiers&.first
          base.type if base&.class&.attributes&.key?(:type)
        end
      end
    end
  end
end
