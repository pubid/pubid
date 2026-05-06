# frozen_string_literal: true

module Pubid
  module Bsi
    class UrnGenerator < Pubid::UrnGenerator::Base
      def generate
        parts = ["urn", "bsi"]

        if identifier.publisher
          pub = identifier.publisher.to_s
          parts << pub.to_s.downcase
        else
          parts << "bs"
        end

        if identifier.prefix
          parts << identifier.prefix.to_s.downcase
        end

        if identifier.flex_prefix
          parts << identifier.flex_prefix.to_s.downcase
        end

        if identifier.number
          number = identifier.number.to_s
          if identifier.iteration && !identifier.iteration.empty?
            number += "[#{identifier.iteration}]"
          end
          parts << number
        end

        if identifier.part
          part = identifier.part.to_s
          parts << "-#{part}"
        end

        if identifier.subpart
          subpart = identifier.subpart.to_s
          parts << "-#{subpart}"
        end

        if identifier.second_number
          second = identifier.second_number.to_s
          parts << "/#{second}"
        end

        if identifier.date
          year = identifier.date.year
          parts << year.to_s
        elsif identifier.year
          parts << identifier.year.to_s
        end

        if identifier.month
          parts << format("%02d", identifier.month)
        end

        if identifier.edition
          parts << "v#{identifier.edition}"
        end

        if identifier.translation_lang
          parts << identifier.translation_lang.to_s.downcase
        elsif identifier.translation_upper
          parts << identifier.translation_upper.to_s.downcase
        end

        if identifier.type
          type = identifier.type&.abbr || identifier.type.to_s
          parts << type.to_s.downcase if type && type.to_s != "BS"
        end

        if identifier.typed_stage
          stage_code = identifier.typed_stage.stage_code
          if stage_code && stage_code != :published
            parts << "stage.#{stage_code}"
          end
        end

        parts.join(":")
      end
    end
  end
end
