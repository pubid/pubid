module Pubid::Ccsds::Renderer
  class Corrigendum < Base
    def render_identifier(params)
      "%<base>s Cor. %<number>s" % params
    end
  end
end
