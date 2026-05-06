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
        pub = maybe(:publisher)
        if pub
          parts << render_publisher(pub,
                                    maybe(:copublishers), **options)
        end

        # Numbering (number, part, subpart)
        num = maybe(:number)
        if num
          parts << render_numbering(num, maybe(:part),
                                    maybe(:subpart), **options)
        end

        # Date
        d = maybe(:date)
        if d
          parts << render_date(d, **options)
        end

        # Stage and type
        stg = maybe(:stage)
        if stg
          parts << render_stage(stg, maybe(:type),
                                has_copublisher: maybe(:copublishers)&.any?, **options)
        end

        # Language codes
        langs = maybe(:languages)
        if langs&.any?
          parts << render_languages(langs, **options)
        end

        parts.compact.join
      end

      private

      def maybe(method_name)
        send(method_name)
      rescue NoMethodError
        nil
      end
    end
  end
end
