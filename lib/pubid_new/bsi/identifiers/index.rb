# frozen_string_literal: true

require_relative "base"
require_relative "../components/code"
require_relative "../components/date"

module PubidNew
  module Bsi
    module Identifiers
      # BSI Index
      # Examples: "BS 5000:Index:1981", "BS 185 Index:1964", "BS 5000 Index Issue 4:1980"
      class Index < Base
        attribute :number, Bsi::Components::Code
        attribute :date, Bsi::Components::Date
        attribute :issue_number, :string  # For "Index Issue N" format
        attribute :original_format, :string  # Preserve ":Index" or " Index" separator

        def self.type
          {
            short: "Index",
            full: "Index",
            names: ["Index"]
          }
        end

        def to_s(lang: :en, lang_single: false)
          number_str = number.respond_to?(:value) ? number.value.to_s : number.to_s

          # Use preserved original format, default to space format
          format = original_format || "space"

          result = "BS #{number_str}"

          if issue_number
            result += " Index Issue #{issue_number}"
          else
            result += if format == "colon"
                       ":Index"
                     else
                       " Index"
                     end
          end

          result += ":#{date.year}" if date
          result
        end
      end
    end
  end
end
