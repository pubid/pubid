# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Iso
    module Identifiers
      # ISO Guide
      # Format: ISO Guide NUMBER:YEAR
      # Format: ISO/IEC Guide NUMBER:YEAR
      class Guide < Base
        def to_s(lang: :en, lang_single: false, with_edition: false)
          result = publisher.to_s
          result += " Guide #{number.value}" if number&.value
          result += ":#{date.year}" if date&.year

          # Add language using the language component's to_s method
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
