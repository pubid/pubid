module Pubid
  module Iec
    module Renderer
      class Corrigendum < Pubid
        def render_identifier(params)
          "COR%<number>s%<year>s" % params
        end
      end
    end
  end
end
