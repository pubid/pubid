# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # AdoptedInternationalStandard wraps ISO/IEC identifiers directly
      # Example: "BS ISO 8601:2019" where ISO 8601:2019 is an ISO identifier object
      # Example: "BS IEC 62600:2020" where IEC 62600:2020 is an IEC identifier object
      class AdoptedInternationalStandard < BritishStandard
        attribute :adopted_identifier, Base, polymorphic: true # ISO/IEC object
        attribute :edition, :string
        attribute :translation_lang, :string
        attribute :translation_upper, :string
        attribute :translation_suffix_type, :string # "version" or "Translation"
        attribute :reaffirmation_year, :string # For "(R2004)" notation
        attribute :expert_commentary, :boolean
        attribute :expert_commentary_topic, :string

        def to_s
          # Get the BSI prefix (BS, PD, DD)
          prefix = if publisher.is_a?(Components::Publisher)
                     publisher.body
                   elsif publisher.is_a?(Array)
                     publisher.join("/")
                   elsif publisher.is_a?(String)
                     publisher
                   else
                     "BS"
                   end

          result = prefix
          result += " #{adopted_identifier}" if adopted_identifier
          result += " ED#{edition}" if edition

          # Reaffirmation notation like (R2004)
          result += " (R#{reaffirmation_year})" if reaffirmation_year

          # Translation - normalize to just "(Language)" format
          # "(French version)", "(French Translation)", "(French)" all become "(French)"
          if translation_lang
            result += " (#{translation_lang})"
          elsif translation_upper
            result += " (#{translation_upper})"
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
      end
    end
  end
end
