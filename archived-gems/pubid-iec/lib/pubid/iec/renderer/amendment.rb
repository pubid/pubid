module Pubid
  module Iec
    module Renderer
      class Amendment < Pubid
        def render_identifier(params)
          "AMD%<number>s%<year>s" % params
        end
      end
    end
  end
end
