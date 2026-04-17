module Pubid
  module Ccsds
    module Renderer
      class Corrigendum < Base
        def render_identifier(params)
          "%<base>s Cor. %<number>s" % params
        end
      end
    end
  end
end
