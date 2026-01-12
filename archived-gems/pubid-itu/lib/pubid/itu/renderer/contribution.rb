module Pubid::Itu::Renderer
  class Contribution < Base
    def render_identifier(params, _opts)
      ("%<series>s-C%<number>s" % params)
    end

    def render_series(series, _opts, _params)
      series
    end

    def render_number(number, _opts, _params)
      number
    end
  end
end
