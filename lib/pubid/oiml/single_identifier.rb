# frozen_string_literal: true

module Pubid
  module Oiml
    class SingleIdentifier < Identifier

      # Base class for OIML single identifiers (non-supplements)
      attribute :publisher, :string
      attribute :code, Oiml::Components::Code
      attribute :date, Pubid::Components::Date
      attribute :edition, :string
      attribute :stage, :string
      attribute :iteration, :string
      attribute :language, :string
      attribute :parsed_format, :string, default: -> {
        "short"
      } # Track parsed format

      # Type is determined by the subclass
      def type
        type_string
      end

      def to_s(format: nil)
        # Use parsed format if not explicitly overridden
        format ||= (parsed_format == "long" ? :long : :short)

        result = "#{publisher} #{type_string} #{code}"

        # Track if we're using Edition format for language spacing
        using_edition_format = false

        # Add edition/date portion
        if edition && date
          # Has edition number: "6th Edition 2015"
          result += " #{edition} Edition #{date.year}"
          using_edition_format = true
        elsif edition
          # Edition without year (shouldn't happen but handle it)
          result += " #{edition}"
          using_edition_format = true
        elsif date
          # Date without edition number
          if format == :long
            result += " Edition #{date.year}"
            using_edition_format = true
          else
            result += ":#{date.year}"
          end
        end

        # Add draft stage if present (iteration + stage)
        if stage || iteration
          result += " "
          result += iteration.to_s if iteration
          result += stage.to_s if stage
        end

        # Add language portion - depends on format
        if language
          result += if using_edition_format || parsed_format == "short_with_space"
                      " (#{language})"
                    else
                      "(#{language})"
                    end
        end

        result
      end

      def edition_portion
        # Deprecated - kept for compatibility
        # Use to_s(format: :long) instead
        if edition && date
          "#{edition} Edition #{date.year}"
        elsif date
          "Edition #{date.year}"
        else
          edition
        end
      end

      # Subclasses override this
      def type_string
        raise NotImplementedError, "Subclasses must implement type_string"
      end

      # Subclasses override this
    end
  end
end
