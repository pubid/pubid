# frozen_string_literal: true

require "lutaml/model"
require_relative "../../serializable"
require_relative "../urn_generator"

module PubidNew
  module Cen
    module Identifiers
      # Base CEN identifier
      # Format: {PUBLISHER} NUMBER[-PART]:YEAR
      class Base < Lutaml::Model::Serializable
        include PubidNew::Serializable

        # Generate URN for this identifier
        #
        # @return [String] URN representation
        def to_urn
          UrnGenerator.new(self).generate
        end

        attribute :publisher, :string, collection: true # EN, CEN, CLC, etc.
        attribute :type, :string # TR, TS, Guide
        attribute :number, :string
        attribute :parts, :string, collection: true
        attribute :year, :integer
        attribute :stage, :string # prEN, FprEN
        attribute :supplements, :string, collection: true # Amendments and corrigenda
        attribute :adopted_identifier, Base, polymorphic: true # Nested identifier object (ISO, IEC, etc.)
        attribute :edition, :string # Edition number

        def to_s
          result = ""

          # Stage or Publisher
          if stage
            result += stage
          elsif publisher&.any?
            result += publisher.join("/")
          end

          # If we have adopted_identifier, render it (contains all info)
          if adopted_identifier
            result += " #{adopted_identifier}"
            # Don't add our own number/parts/year - they're in adopted_identifier
          else
            # Only render our own fields if no adoption
            # Type - use space for Guide, slash for TR/TS
            if type
              sep = type == "Guide" ? " " : "/"
              result += "#{sep}#{type}"
            end

            result += " #{number}"
            result += parts.map { |p| "-#{p}" }.join if parts&.any?
            result += ":#{year}" if year

            # Supplements
            if supplements&.any?
              supplements.each do |supp|
                sep = supp[:type] == :amendment ? "/" : "+"
                result += "#{sep}#{supp[:type] == :amendment ? 'A' : 'AC'}"
                result += supp[:number] if supp[:number] && !supp[:number].empty?
                result += ":#{supp[:year]}" if supp[:year]
              end
            end

            # Edition
            result += " ED#{edition}" if edition
          end

          result
        end

        def ==(other)
          return false unless other.is_a?(Base)

          publisher == other.publisher && number == other.number &&
            parts == other.parts && year == other.year
        end
      end
    end
  end
end
