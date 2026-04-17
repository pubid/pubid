module Pubid
  module Iec
    module Renderer
      class InterpretationSheet < Pubid
        def render_identifier(params)
          type_prefix = params[:stage].nil? || params[:stage].to_s.empty? ? "ISH" : ""

          "%<base>s/%<stage>s#{type_prefix}%<number>s%<year>s" % params
        end

        def render_stage(stage, _opts, _params)
          stage
        end

        def render_year(year, _opts, _params)
          ":#{year}"
        end
      end
    end
  end
end
