require_relative "base"

module Pubid
  module Iso
    module Renderer
      class InternationalStandard < Base
        def omit_post_publisher_symbol?(typed_stage, stage, opts)
          return true if stage.is_a?(Pubid::Core::TypedStage) && stage.abbr == :is

          super
        end

        def postrender_stage(stage, opts, params)
          return if stage.is_a?(Pubid::Core::TypedStage) && stage.abbr == :is

          super
        end
      end
    end
  end
end
