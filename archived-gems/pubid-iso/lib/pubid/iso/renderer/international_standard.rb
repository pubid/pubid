require_relative "base"

module Pubid
  module Iso
    module Renderer
      class InternationalStandard < Base
        def omit_post_publisher_symbol?(typed_stage, stage)
          # return false unless typed_stage

          !stage.nil? && !typed_stage.nil?
        end
      end
    end
  end
end
