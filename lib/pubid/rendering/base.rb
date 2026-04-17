# frozen_string_literal: true

require_relative "publisher"
require_relative "numbering"
require_relative "date"
require_relative "supplement"
require_relative "stage"
require_relative "language"
require_relative "format"

module Pubid
  module Rendering
    module Base
      include Pubid::Rendering::Publisher
      include Pubid::Rendering::Numbering
      include Pubid::Rendering::Date
      include Pubid::Rendering::Supplement
      include Pubid::Rendering::Stage
      include Pubid::Rendering::Language
      include Pubid::Rendering::Format

      # Base rendering method to be composed by subclasses
      # @param options [Hash] rendering options
      # @return [String] formatted identifier string
      def render_base(**options)
        parts = []

        # Publisher/copublisher
        if respond_to?(:publisher) && publisher
          parts << render_publisher(publisher,
                                    respond_to?(:copublishers) ? copublishers : nil, **options)
        end

        # Numbering (number, part, subpart)
        if respond_to?(:number) && number
          parts << render_numbering(number, respond_to?(:part) ? part : nil,
                                    respond_to?(:subpart) ? subpart : nil, **options)
        end

        # Date
        if respond_to?(:date) && date
          parts << render_date(date, **options)
        end

        # Stage and type
        if respond_to?(:stage) && stage
          parts << render_stage(stage, respond_to?(:type) ? type : nil,
                                has_copublisher: respond_to?(:copublishers) && copublishers&.any?, **options)
        end

        # Language codes
        if respond_to?(:languages) && languages&.any?
          parts << render_languages(languages, **options)
        end

        parts.compact.join
      end
    end
  end
end
