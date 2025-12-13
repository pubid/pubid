# frozen_string_literal: true

module PubidNew
  module Oiml
    class SingleIdentifier < Identifier
      # Base class for OIML single identifiers (non-supplements)
      attribute :publisher, :string
      attribute :code, Oiml::Components::Code
      attribute :date, PubidNew::Components::Date
      attribute :stage, :string
      attribute :iteration, :string
      attribute :language, :string

      # Type is determined by the subclass
      def type
        type_string
      end

      def to_s
        result = "#{publisher} #{type_string} #{code}"

        # Add date if present
        result += ":#{date.year}" if date

        # Add draft stage if present (iteration + stage)
        if stage || iteration
          result += " "
          result += iteration.to_s if iteration
          result += stage.to_s if stage
        end

        # Add language portion if present
        result += "(#{language})" if language

        result
      end

      # Subclasses override this
      def type_string
        raise NotImplementedError, "Subclasses must implement type_string"
      end
    end
  end
end