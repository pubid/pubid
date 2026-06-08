# frozen_string_literal: true

module Pubid
  module Jis
    module Identifiers
      # Base class for all JIS identifiers
      # Provides common attributes and behavior
      class Base < Pubid::Identifier
        # Generate URN for this identifier
        #
        # @return [String] URN representation

        attribute :code, Pubid::Jis::Components::Code
        attribute :year, :integer
        attribute :language, :string # "E" or "J"
        attribute :all_parts, :boolean, default: -> { false }
        # Reaffirmation (再確認): a trailing "R" on the year marks an edition
        # that was reaffirmed without revision (e.g. ":2019R").
        attribute :reaffirmed, :boolean, default: -> { false }

        def initialize(code: nil, series: nil, number: nil, parts: nil,
                      year: nil, language: nil, all_parts: false,
                      reaffirmed: false)
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
          @reaffirmed = reaffirmed
        end

        # Publisher is always JIS
        def publisher
          "JIS"
        end

        def all_parts?
          all_parts == true
        end

        def reaffirmed?
          reaffirmed == true
        end

        # Render a year with its reaffirmation marker, e.g. "2019R".
        def year_with_reaffirmation
          "#{year}#{'R' if reaffirmed?}"
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
            all_parts == other.all_parts &&
            reaffirmed == other.reaffirmed
        end

        # Basic string representation (override in subclasses)
        def to_s
          parts = [publisher, code.to_s]
          parts << ":#{year_with_reaffirmation}" if year
          parts << "(#{language})" if language
          parts << "（規格群）" if all_parts?
          parts.join(" ")
        end
      end
    end
  end
end
