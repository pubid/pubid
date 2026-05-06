# frozen_string_literal: true

module Pubid
  module UrnGenerator
    # Base class for all flavor-specific URN generators.
    # Provides template methods for common URN parts.
    # Flavors subclass and override only what differs.
    class Base
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      def generate
        parts = ["urn", urn_namespace]
        parts << urn_publisher if urn_publisher
        parts << urn_type if urn_type
        parts << urn_number if urn_number
        parts << urn_part if urn_part
        parts << urn_subpart if urn_subpart
        parts << urn_year if urn_year
        parts << urn_edition if urn_edition
        parts << urn_language if urn_language
        parts.join(":")
      end

      # Template methods — override in subclasses

      def urn_namespace
        flavor_name.downcase
      end

      def urn_publisher
        return nil unless identifier.publisher

        identifier.publisher.to_s.downcase
      end

      def urn_type
        nil
      end

      def urn_number
        val = identifier.number
        return nil unless val

        val.is_a?(Components::Code) ? val.value.to_s : val.to_s
      end

      def urn_part
        val = identifier.part
        return nil unless val

        "-#{val.is_a?(Components::Code) ? val.value : val}"
      end

      def urn_subpart
        val = identifier.subpart
        return nil unless val

        "-#{val.is_a?(Components::Code) ? val.value : val}"
      end

      def urn_year
        if identifier.date
          year = identifier.date.is_a?(Components::Date) ? identifier.date.year : identifier.date.to_s
          return year.to_s if year
        end
        if maybe(:year)
          return identifier.year.to_s
        end

        nil
      end

      def urn_edition
        return nil unless identifier.edition

        num = identifier.edition.is_a?(Components::Edition) ? identifier.edition.number : identifier.edition
        return nil unless num

        "ed.#{num}"
      end

      def urn_language
        langs = maybe(:languages)
        return nil unless langs&.any?

        langs.map(&:code).join(",")
      end

      def maybe(method_name)
        identifier.send(method_name)
      rescue NoMethodError
        nil
      end

      private

      def flavor_name
        parts = identifier.class.name.split("::")
        parts[1] || "unknown"
      end
    end
  end
end
