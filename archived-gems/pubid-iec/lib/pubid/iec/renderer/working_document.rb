module Pubid
  module Iec
    module Renderer
      class WorkingDocument < Pubid
        def render_identifier(params)
          "%<technical_committee>s/%<number>s%<stage>s" % params
        end

        def render_stage(stage, _opts, _params)
          "/#{stage}"
        end
      end
    end
  end
end
