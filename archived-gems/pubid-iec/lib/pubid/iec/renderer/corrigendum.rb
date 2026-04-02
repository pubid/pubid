module Pubid::Iec::Renderer
  class Corrigendum < Pubid
    def render_identifier(params)
      "COR%<number>s%<year>s" % params
    end
  end
end
