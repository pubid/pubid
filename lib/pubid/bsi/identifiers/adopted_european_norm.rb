# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # AdoptedEuropeanNorm wraps CEN identifiers
      # Example: "BS EN 10077-1:2006" where EN 10077-1:2006 is a CEN identifier object
      # Example: "BS EN ISO 8601:2019" where EN ISO 8601:2019 is a CEN AdoptedEuropeanNorm wrapping ISO
      class AdoptedEuropeanNorm < BritishStandard
        attribute :adopted_identifier, Base, polymorphic: true # CEN object
        attribute :edition, :string
        attribute :translation_lang, :string
        attribute :translation_upper, :string
        attribute :translation_suffix_type, :string # "version" or "Translation"
        attribute :reaffirmation_year, :string # For "(R2004)" notation
        attribute :expert_commentary, :boolean
        attribute :expert_commentary_topic, :string

        def to_s(lang: :en, lang_single: false)
          # Get the BSI prefix (BS, PD, DD)
          prefix = case publisher
                   when Components::Publisher
                     publisher.body
                   when Array
                     publisher.join("/")
                   when String
                     publisher
                   else
                     "BS"
                   end

          result = prefix
          result += " #{adopted_identifier}" if adopted_identifier
          result += " ED#{edition}" if edition

          # Reaffirmation notation like (R2004)
          result += " (R#{reaffirmation_year})" if reaffirmation_year

          # Translation - preserve the "version" or "Translation" suffix if present
          if translation_lang
            result += if translation_suffix_type == "version"
                        " (#{translation_lang} version)"
                      elsif translation_suffix_type == "Translation"
                        " (#{translation_lang} Translation)"
                      else
                        " (#{translation_lang})"
                      end
          elsif translation_upper
            result += if translation_suffix_type == "Translation"
                        " (#{translation_upper} Translation)"
                      else
                        " (#{translation_upper})"
                      end
          end

          # ExpertCommentary suffix
          if expert_commentary
            result += if expert_commentary_topic
                        " ExComm (#{expert_commentary_topic})"
                      else
                        " ExComm"
                      end
          end

          result
        end

        # Delegate common methods to adopted identifier
        def number
          adopted_identifier&.number
        end

        def year
          adopted_identifier&.year if adopted_identifier&.methods&.include?(:year)
        end

        def date
          adopted_identifier&.date if adopted_identifier&.methods&.include?(:date)
        end

        def parts
          adopted_identifier&.parts if adopted_identifier&.methods&.include?(:parts)
        end

        def part
          adopted_identifier&.part if adopted_identifier&.methods&.include?(:part)
        end

        def subpart
          adopted_identifier&.subpart if adopted_identifier&.methods&.include?(:subpart)
        end
      end
    end
  end
end
