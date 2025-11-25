# frozen_string_literal: true

require_relative "base"
require_relative "../../components/typed_stage"

module PubidNew
  module Iso
    module Identifiers
      # ISO Guide
      # Format: ISO Guide NUMBER:YEAR
      # Format: ISO/IEC Guide NUMBER:YEAR
      class Guide < Base
        def to_s(lang: :en, lang_single: false, with_edition: false)
          result = publisher.to_s

          # Add stage if present
          if stage&.abbr
            result += publisher.has_copublisher? ? " #{stage.abbr}" : "/#{stage.abbr}"
          end

          # Always add "Guide" type with proper separator
          has_prefix = stage&.abbr || publisher.has_copublisher?
          sep = has_prefix ? " " : "/"
          result += "#{sep}Guide"

          # Add number
          result += " #{number.value}" if number&.value

          # Add part (with dash)
          result += "-#{part.value}" if part&.value

          # Add subpart (with dash)
          result += "-#{subpart.value}" if subpart&.value

          # Add stage iteration if present
          result += ".#{stage_iteration.value}" if stage_iteration&.value

          # Add year
          result += ":#{date.year}" if date&.year

          # Add edition if with_edition flag is set
          result += " #{edition.to_s}" if with_edition && edition&.number

          # Add language
          if languages&.any?
            result += "(#{languages.map do |l|
              l.to_s(lang_single: lang_single)
            end.join('/')})"
          end

          result
        end
      end
    end
  end
end
