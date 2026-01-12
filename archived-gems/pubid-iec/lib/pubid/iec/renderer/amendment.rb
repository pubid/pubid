module Pubid::Iec::Renderer
  class Amendment < Pubid
    def render_identifier(params)
      "AMD%<number>s%<year>s" % params
    end
  end
end
