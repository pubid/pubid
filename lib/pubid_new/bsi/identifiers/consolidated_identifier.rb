# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Bsi
    module Identifiers
      # Consolidated Identifier - contains base document plus supplements
      # Example: "BS 4592-0:2006+A1:2012" = [BS 4592-0:2006, Amendment 1:2012]
      class ConsolidatedIdentifier < Base
        attribute :identifiers, Base, polymorphic: true, collection: true

        def to_s
          result = identifiers.map.with_index do |id, idx|
            if idx == 0
              # First identifier renders without suffixes (pdf, tc, excomm)
              base_str =
                id.is_a?(Base) ? render_base_without_suffixes(id) : id.to_s
              base_str
            else
              # Supplements render with + prefix
              if id.is_a?(Amendment)
                "+A#{id.amendment_number}:#{id.amendment_year}"
              elsif id.is_a?(Corrigendum)
                result = "+C#{id.corrigendum_number}"
                result += ":#{id.corrigendum_year}" if id.corrigendum_year
                result
              else
                # Fallback for other types
                id.to_s
              end
            end
          end.join

          # Add suffixes AFTER supplements
          result += " ExComm" if identifiers.first&.excomm
          result += " PDF" if identifiers.first&.pdf
          result += " - TC" if identifiers.first&.tc

          # Translation
          if identifiers.first&.translation
            result += " (#{identifiers.first.translation})"
          end

          result
        end

        # Delegate to first identifier (base document)
        def publisher
          identifiers&.first&.publisher
        end

        def number
          identifiers&.first&.number
        end

        def year
          identifiers&.first&.year
        end

        def parts
          identifiers&.first&.parts
        end

        def type
          identifiers&.first&.type
        end

        private

        def render_base_without_suffixes(base_id)
          # Render base identifier but skip excomm, pdf, tc
          result = ""

          if base_id.national_annex
            result += "NA to "
          end

          result += base_id.publisher.to_s

          if base_id.adopted_identifier
            result += " #{base_id.adopted_identifier.to_s}"
          else
            result += " #{base_id.adopted_org}" if base_id.adopted_org
            result += " #{base_id.adopted_type}" if base_id.adopted_type
            result += " #{base_id.number}" if base_id.number
            result += "/#{base_id.collection_number}" if base_id.collection_number
            result += base_id.parts.map { |p| "-#{p}" }.join if base_id.parts&.any?
            result += " v#{base_id.version}" if base_id.version
            result += ":#{base_id.year}" if base_id.year
            result += "-#{base_id.month}" if base_id.month
          end

          result
        end
      end
    end
  end
end