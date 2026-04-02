# frozen_string_literal: true

module Pubid
  module Rendering
    module Stage
      # Render stage and type abbreviations
      # @param stage [Components::Stage] stage component
      # @param type [Components::Type] type component
      # @param has_copublisher [Boolean] whether copublisher exists
      # @param options [Hash] rendering options
      # @return [String] formatted stage/type string
      def render_stage(stage, type = nil, has_copublisher: false, **options)
        result = ""

        if stage&.abbr
          separator = has_copublisher ? " " : "/"
          result += "#{separator}#{stage.abbr}"
        end

        if type&.abbr && type.abbr != default_type_abbr
          result += type_separator(has_copublisher, result) + type.abbr
        end

        result
      end

      private

      def default_type_abbr
        "IS" # Override in flavors
      end

      def type_separator(has_copublisher, has_stage)
        has_copublisher || has_stage.empty? ? " " : "/"
      end
    end
  end
end
