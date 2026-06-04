# frozen_string_literal: true

module Pubid
  module Renderers
    class GuideRenderer < HumanReadable
      private

      def render_publisher_and_stage(context)
        ann = context.annotated
        pub_str = annotate(@id.publisher.render(context:), "publisher",
                           annotated: ann) if @id.publisher
        stage_str = @id.typed_stage.render(context:) if @id.typed_stage

        if stage_str && !stage_str.empty?
          stage_str = annotate(stage_str, typed_stage_css(@id.typed_stage),
                               annotated: ann)
          "#{pub_str} #{stage_str}"
        else
          pub_str
        end
      end
    end
  end
end
