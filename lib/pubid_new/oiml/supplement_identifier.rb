# frozen_string_literal: true

module PubidNew
  module Oiml
    class SupplementIdentifier < Identifier
      # Base class for OIML supplements (amendments, annexes)
      # These wrap a base identifier like ISO amendments
      attribute :base_identifier, Oiml::Identifier
      attribute :year, :string
      attribute :language, :string
      attribute :parsed_format, :string, default: -> { "short" }  # Track supplement's parsed format

      def to_s(format: :short)
        # Determine base format: explicit parameter takes priority, else use parsed format
        base_format = if format && format != :short
          format  # Use explicit override
        elsif base_identifier.respond_to?(:parsed_format) && base_identifier.parsed_format == "long"
          :long
        else
          :short
        end

        # Render base with determined format (preserves Edition vs colon)
        base_str = base_identifier.to_s(format: base_format)
        base_str = base_str.sub(/\s*\([^)]+\)\s*$/, '').strip  # Remove language from base

        result = "#{supplement_type} (#{year}) to #{base_str}"

        # Supplements ALWAYS add space before their language
        result += " (#{language})" if language

        result
      end

      # Subclasses override this
      def supplement_type
        raise NotImplementedError, "Subclasses must implement supplement_type"
      end
    end
  end
end