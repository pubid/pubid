# frozen_string_literal: true

require_relative 'publisher'
require_relative 'numbering'
require_relative 'date'
require_relative 'supplement'
require_relative 'stage'
require_relative 'language'
require_relative 'format'

module PubidNew
  module Rendering
    module Base
      include PubidNew::Rendering::Publisher
      include PubidNew::Rendering::Numbering
      include PubidNew::Rendering::Date
      include PubidNew::Rendering::Supplement
      include PubidNew::Rendering::Stage
      include PubidNew::Rendering::Language
      include PubidNew::Rendering::Format

      # Base rendering method to be composed by subclasses
      def render_base(**options)
        parts = []

        has_copub = respond_to?(:copublisher) && !!copublisher
        has_copub ||= respond_to?(:copublishers) && !!copublishers

        parts << render_publisher(publisher, copublisher, **options)
        parts << render_numbering(number, part, subpart, **options)
        parts << render_date(date, **options)
        parts << render_stage(stage, type, has_copublisher: has_copub, **options)
        parts << render_languages(languages, **options)

        parts.compact.join
      end
    end
  end
end
