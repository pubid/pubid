# frozen_string_literal: true

module PubidNew
  module Oiml
    class SingleIdentifier < Identifier
      # Base class for OIML single identifiers (non-supplements)
      attribute :publisher, :string
      attribute :code, Oiml::Components::Code
      attribute :date, PubidNew::Components::Date
      attribute :edition, :string
      attribute :stage, :string
      attribute :iteration, :string
      attribute :language, :string

      # Type is determined by the subclass
      def type
        type_string
      end

      def to_s
        result = "#{publisher} #{type_string} #{code}"

        # Add edition if present (before or instead of date)
        if edition
          result += " #{edition_portion}"
        elsif date
          # Add date if present and no edition
          result += ":#{date.year}"
        end

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

      def edition_portion
        # Handle both "6th Edition 2015" and "Edition 2013" formats
        if edition && date
          # "6th Edition 2015"
          "#{edition} Edition #{date.year} (#{language})" if language
        elsif date
          # "Edition 2013"
          "Edition #{date.year} (#{language})" if language
        else
          edition
        end
      end

      # Subclasses override this
      def type_string
        raise NotImplementedError, "Subclasses must implement type_string"
      end

      private

      # Subclasses override this
    end
  end
end