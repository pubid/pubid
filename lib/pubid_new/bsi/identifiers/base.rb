# frozen_string_literal: true

require "lutaml/model"
require_relative "../../components/edition"

module PubidNew
  module Bsi
    module Identifiers
      # Base BSI identifier
      # Format: {TYPE} NUMBER[-PART]:YEAR
      # Types: BS, PAS, PD, DD, Flex, NA
      class Base < Lutaml::Model::Serializable
        attribute :type, :string  # BS, PAS, PD, DD, Flex, NA
        attribute :stage, :string  # DD (draft) for PD documents
        attribute :adopted_org, :string  # CISPR, IEC, ISO, EN, etc.
        attribute :adopted_type, :string  # TR, TS for adopted documents
        attribute :number, :string
        attribute :parts, :string, collection: true
        attribute :year, :integer
        attribute :month, :string
        attribute :version, :string  # For Flex documents
        attribute :supplements, :string, collection: true  # Amendments and corrigenda (stored as serialized hashes)
        attribute :adopted_identifier, Base, polymorphic: true  # Nested identifier object
        attribute :national_annex, :boolean, default: -> { false }
        attribute :excomm, :boolean, default: -> { false }
        attribute :pdf, :boolean, default: -> { false }
        attribute :tc, :boolean, default: -> { false }
        attribute :collection_number, :string
        attribute :edition, PubidNew::Components::Edition, default: -> { nil }
        attribute :translation, :string  # Language translation like "German", "French"

        def publisher
          if type == "Flex"
            "BSI Flex"
          elsif national_annex
            "NA"
          elsif stage == "DD"
            "DD"
          else
            type
          end
        end

        def to_s
          result = ""

          # National Annex prefix with supplements
          if national_annex && supplements&.any?
            result += "NA"
            supplements.each do |supp|
              if supp.is_a?(Hash)
                result += "+#{supp[:type] == :amendment ? 'A' : 'C'}#{supp[:number]}:#{supp[:year]}"
              end
            end
            result += " to "
          elsif national_annex
            result += "NA to "
          end

          result += publisher.to_s

          # If we have adopted_identifier, render it completely (it contains all info)
          if adopted_identifier
            result += " #{adopted_identifier.to_s}"
            # Don't add number/parts/year since they're in adopted_identifier
          else
            # Only render our own number/parts/year if no adoption
            # Don't add leading space for adopted_org if publisher is empty/nil
            if adopted_org
              result += publisher.to_s.empty? ? adopted_org : " #{adopted_org}"
            end
            result += " #{adopted_type}" if adopted_type  # type after org (e.g., CISPR TR)
            result += " #{number}" if number
            result += "/#{collection_number}" if collection_number
            result += parts.map { |p| "-#{p}" }.join if parts&.any?
            result += " v#{version}" if version
            result += ":#{year}" if year
            result += "-#{month}" if month

            # Supplements (for non-NA)
            if supplements&.any? && !national_annex
              supplements.each do |supp|
                if supp.is_a?(Hash)
                  result += "+#{supp[:type] == :amendment ? 'A' : 'C'}#{supp[:number]}"
                  result += ":#{supp[:year]}" if supp[:year]
                end
              end
            end
          end

          result += " ExComm" if excomm
          result += " PDF" if pdf
          result += " - TC" if tc

          # Edition at BSI level (not adopted level)
          result += " ED#{edition.number}" if edition && edition.number

          # Translation
          result += " (#{translation})" if translation

          result
        end

        def ==(other)
          return false unless other.is_a?(Base)
          type == other.type && number == other.number && parts == other.parts && year == other.year
        end
      end
    end
  end
end