# frozen_string_literal: true

module Pubid
  module Renderers
    class IwaRenderer < HumanReadable
      def render(context:, with_edition: false)
        parts = []
        parts << @id.typed_stage.render(context:) if @id.typed_stage
        parts << render_number_portion(context)
        result = parts.compact.join(" ")
        result << render_language_portion(context, with_edition: with_edition)
        result
      end
    end
  end
end
