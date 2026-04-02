# frozen_string_literal: true

require "lutaml/model"
require_relative "base"

module PubidNew
  module Bsi
    module Identifiers
      # BundledIdentifier represents multiple standards published together
      # Examples:
      #   BS SP 10 & 11:1949
      #   BS 2SP 68 to BS 2SP 71:1973
      #   BS SP 13; 14; 15 and 16:1949
      #   BS 4048:Parts 1 and 2:1966
      class BundledIdentifier < Base
        attribute :identifiers, Base, collection: true, polymorphic: true
        attribute :separators, :string, collection: true # Separators between identifiers
        attribute :common_year, Bsi::Components::Date # Year applied to all if present
        attribute :bundle_type, :string # "Parts", "Sections", or nil for regular bundles

        def to_s(lang: :en, lang_single: false)
          return "" if identifiers.nil? || identifiers.empty?

          # Special case: Parts/Sections bundles like "BS 4048:Parts 1 and 2:1966"
          if bundle_type
            base_id = identifiers.first
            parts_list = identifiers[1..].map do |id|
              # Extract just the part number
              if id.respond_to?(:part)
                part_val = id.part.respond_to?(:value) ? id.part.value : id.part
                part_val.to_s
              else
                id.to_s
              end
            end.join(" and ")

            result = "#{base_id.to_s.sub(/:.*$/,
                                         '')}:#{bundle_type} #{parts_list}"
            result += ":#{common_year.year}" if common_year
            return result
          end

          # Regular bundle: render based on explicit markers
          parts = []

          identifiers.each_with_index do |id, i|
            # Check metadata flags for how item was parsed
            explicit_prefix = id.instance_variable_get(:@explicit_prefix)
            explicit_publisher = id.instance_variable_get(:@explicit_publisher)

            if i.zero?
              # First item always uses full form
              parts << id.to_s
            elsif explicit_publisher
              # Full form: has explicit publisher (e.g., "BS SP 50")
              parts << id.to_s
            elsif explicit_prefix
              # Prefix-only form: has explicit prefix but no publisher (e.g., "SP 138")
              abbrev_str = ""
              if id.respond_to?(:prefix) && id.prefix && !id.prefix.to_s.empty?
                abbrev_str = id.prefix.to_s
              end
              if id.number
                number_val = id.number.respond_to?(:value) ? id.number.value : id.number
                abbrev_str += " " if !abbrev_str.empty?
                abbrev_str += number_val.to_s
              end
              if id.part
                part_val = id.part.respond_to?(:value) ? id.part.value : id.part
                abbrev_str += "-#{part_val}"
              end
              parts << abbrev_str
            else
              # Minimal form: no explicit markers (e.g., "125")
              abbrev_str = ""
              if id.number
                number_val = id.number.respond_to?(:value) ? id.number.value : id.number
                abbrev_str = number_val.to_s
              end
              if id.part
                part_val = id.part.respond_to?(:value) ? id.part.value : id.part
                abbrev_str += "-#{part_val}"
              end
              parts << abbrev_str
            end

            # Add separator - preserve original spacing
            if i < identifiers.length - 1
              sep = separators[i] || " and "
              parts << sep
            end
          end

          result = parts.join

          # Add common year if present and not already in last identifier
          if common_year && !result.match?(/:#{common_year.year}$/)
            result += ":#{common_year.year}"
          end

          result
        end

        def <=>(other)
          return nil unless other.is_a?(BundledIdentifier)

          # Compare first identifier
          identifiers.first <=> other.identifiers.first
        end
      end
    end
  end
end
