# frozen_string_literal: true

module Pubid
  module UrnGenerator
    # Base class for all flavor-specific URN generators.
    # Provides template methods for common URN parts.
    # Flavors subclass and override only what differs.
    class Base
      URN_CONTEXT = Rendering::RenderingContext.urn.freeze
      private_constant :URN_CONTEXT

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
        pub = maybe(:publisher)
        return nil unless pub

        pub.is_a?(Components::Publisher) ? pub.render(context: URN_CONTEXT) : pub.to_s.downcase
      end

      def urn_type
        nil
      end

      def urn_number
        val = maybe(:number) || maybe(:code)
        return nil unless val

        val.is_a?(Components::Code) ? val.render(context: URN_CONTEXT) : val.to_s
      end

      def urn_part
        val = maybe(:part)
        return nil unless val

        "-#{val.is_a?(Components::Code) ? val.render(context: URN_CONTEXT) : val}"
      end

      def urn_subpart
        val = maybe(:subpart)
        return nil unless val

        "-#{val.is_a?(Components::Code) ? val.render(context: URN_CONTEXT) : val}"
      end

      def urn_year
        date = maybe(:date)
        if date.is_a?(Components::Date)
          return date.render(context: URN_CONTEXT) if date.present?
        elsif date
          return date.to_s
        end
        maybe(:year)&.to_s
      end

      def urn_edition
        ed = maybe(:edition)
        return nil unless ed

        num = ed.is_a?(Components::Edition) ? ed.number : ed
        return nil unless num

        "ed.#{num}"
      end

      def urn_language
        langs = maybe(:languages)
        return nil unless langs&.any?

        langs.map(&:code).join(",")
      end

      def maybe(method_name)
        return nil unless identifier.class.attributes.key?(method_name)

        identifier.public_send(method_name)
      end

      private

      def flavor_name
        parts = identifier.class.name.split("::")
        parts[1] || "unknown"
      end
    end
  end
end
