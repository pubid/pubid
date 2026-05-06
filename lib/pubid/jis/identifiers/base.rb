# frozen_string_literal: true

module Pubid
  module Jis
    module Identifiers
      # Base class for all JIS identifiers
      # Provides common attributes and behavior
      class Base < Lutaml::Model::Serializable
        # Generate URN for this identifier
        #
        # @return [String] URN representation

        attribute :code, Pubid::Jis::Components::Code
        attribute :year, :integer
        attribute :language, :string # "E" or "J"
        attribute :all_parts, :boolean, default: -> { false }

        def initialize(code: nil, series: nil, number: nil, parts: nil,
                      year: nil, language: nil, all_parts: false)
          if code
            @code = code
          elsif series && number
            @code = Components::Code.new(
              series: series,
              number: number,
              parts: parts || [],
            )
          end
          @year = year
          @language = language
          @all_parts = all_parts
        end

        # Publisher is always JIS
        def publisher
          "JIS"
        end

        def all_parts?
          all_parts == true
        end

        # Comparison with all_parts logic
        # When either identifier has all_parts=true, compare only series and number
        def ==(other)
          return false unless other.is_a?(Base)

          if all_parts? || other.all_parts?
            # Compare only series and number, ignore year, parts, all_parts
            return code.series == other.code.series &&
                code.number == other.code.number
          end

          # Normal full comparison
          code == other.code &&
            year == other.year &&
            language == other.language &&
            all_parts == other.all_parts
        end

        # Basic string representation (override in subclasses)
        def to_s
          parts = [publisher, code.to_s]
          parts << ":#{year}" if year
          parts << "(#{language})" if language
          parts << "（規格群）" if all_parts?
          parts.join(" ")
        end
      end
    end
  end
end
