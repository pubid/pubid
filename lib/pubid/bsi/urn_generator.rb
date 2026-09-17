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

        # Read identity from the wrapped document when the wrapper has none of
        # its own. A wrapper — an adopted European norm, a bundle, a set —
        # carries no number, part, subpart or date, so a
        # "DD ENV ISO 11079:1999" (which adopts a CEN prestandard that is itself
        # a wrapper around the ISO standard) emitted the identity-free
        # `urn:bsi:dd` — the same URN as every other DD adoption. `#root`
        # recurses to the origin document, and for a non-wrapper it is `self`,
        # so this changes nothing for an ordinary identifier.
        urn_number = identity(:number)
        if urn_number
          number = urn_number.to_s
          if identifier.iteration && !identifier.iteration.empty?
            number += "[#{identifier.iteration}]"
          end
          parts << number
        end

        urn_part = identity(:part)
        parts << "-#{urn_part}" if urn_part

        urn_subpart = identity(:subpart)
        parts << "-#{urn_subpart}" if urn_subpart

        if identifier.second_number
          second = identifier.second_number.to_s
          parts << "/#{second}"
        end

        urn_date = identity(:date)
        if urn_date.is_a?(::Pubid::Components::Date) && urn_date.present?
          parts << urn_date.render(context: URN_CONTEXT)
        elsif (urn_year = identity(:year))
          parts << urn_year.to_s
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

      private

      # An identity attribute of the identifier, or of the document it wraps.
      # `#root` is `self` for a non-wrapper, so an ordinary identifier reads its
      # own value twice and nothing changes.
      def identity(attr)
        own = identifier.public_send(attr)
        return own if own

        root = identifier.root
        root.equal?(identifier) ? nil : root.public_send(attr)
      end
    end
  end
end
