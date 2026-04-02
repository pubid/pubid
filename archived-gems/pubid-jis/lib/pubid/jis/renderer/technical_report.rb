require_relative "base"

module Pubid::Jis::Renderer
  class TechnicalReport < Base
    def render_identifier(params)
      "%<publisher>s TR%<series>s %<number>s%<part>s%<year>s%<all_parts>s" % params
    end
  end
end
