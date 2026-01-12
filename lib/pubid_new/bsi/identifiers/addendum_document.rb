# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Bsi
    module Identifiers
      # Addendum Document Identifier
      # Contains a base identifier plus addendum parameters
      # Supports various formats:
      # "BS 1501-2 Addendum No. 1:1973"
      # "BS 1902-2.3:Addendum No. 1:1976"
      # "BS 2000-0:Addendum 1:1983"
      # "BS 6034:1981:Addendum No. 1:1986"
      class AddendumDocument < Base
        attribute :base_identifier, Base, polymorphic: true
        attribute :addendum_number, :string
        attribute :addendum_year, :integer
        attribute :addendum_type, :string, default: -> { "No." }  # "No." or empty for "Addendum N"
        attribute :separator, :string, default: -> { ":" }  # Separator before Addendum (":" or " ")

        def to_s(lang: :en, lang_single: false)
          result = base_identifier.to_s(lang: lang, lang_single: lang_single)

          # Determine separator - if separator is explicitly ":", use it
          # Otherwise if base has year and doesn't already have double colon, use space
          base_has_year = base_identifier.to_s =~ /:(\d{4})$/

          sep = if separator == ":"
                  ":"
                elsif base_has_year && base_identifier.to_s !~ /:\d{4}:/
                  " "
                else
                  separator
                end

          # Format: "BASE:Addendum No. N:YEAR" or "BASE Addendum No. N:YEAR" or "BASE:Addendum N:YEAR"
          result += sep
          result += "Addendum"

          # Add space after "Addendum" if there's a type prefix (like "No.")
          if !addendum_type.empty?
            result += " #{addendum_type}"
            result += " "
          else
            # No type prefix, but still need space before number
            result += " "
          end

          result += addendum_number.to_s
          result += ":#{addendum_year}" if addendum_year

          result
        end

        def publisher
          base_identifier&.publisher
        end
      end
    end
  end
end
