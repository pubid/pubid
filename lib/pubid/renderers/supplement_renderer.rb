# frozen_string_literal: true

module Pubid
  module Renderers
    class SupplementRenderer < HumanReadable
      def render(context:, with_edition: false, **_opts)
        parts = []

        base_str = @id.base.to_s(
          with_edition: with_edition,
          stage_format_long: context.stage_format_long,
          with_date: context.with_date,
          annotated: context.annotated,
        )

        # A supplement without a typed_stage is malformed per ISO DIR
        # composition (pubid#680): emitting "#{base}/" hides upstream state
        # corruption, so fail loudly at the render seam. The historic nil
        # producer (metanorma-iso's draft-biblio flow) now stops stripping
        # the stage (metanorma-iso#1696).
        unless @id.typed_stage
          raise ArgumentError,
                "cannot render supplement without a typed_stage: #{base_str}"
        end

        stage_str = annotate(@id.typed_stage.render(context:),
                             typed_stage_css(@id.typed_stage),
                             annotated: context.annotated)
        parts << "#{base_str}/#{stage_str}"

        num_port = render_number_portion(context)
        if num_port && !num_port.empty? && !num_port.start_with?(":")
          parts << (stage_str&.end_with?(".") ? "" : " ")
        end
        parts << num_port

        parts << " #{render_edition_portion(context)}" if with_edition && @id.edition&.number
        if @id.languages&.any?
          parts << render_language_portion(context,
                                           with_edition: with_edition)
        end
        parts.compact.join
      end
    end
  end
end
