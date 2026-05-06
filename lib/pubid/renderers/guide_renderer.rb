# frozen_string_literal: true

module Pubid
  module Renderers
    class GuideRenderer < HumanReadable
      private

      def render_publisher_and_stage(context)
        pub_str = @id.publisher.render(context:) if @id.publisher
        stage_str = @id.typed_stage.render(context:) if @id.typed_stage

        if stage_str && !stage_str.empty?
          "#{pub_str} #{stage_str}"
        else
          pub_str
        end
      end
    end
  end
end
