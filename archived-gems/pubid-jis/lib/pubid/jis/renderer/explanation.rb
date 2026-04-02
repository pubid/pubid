require_relative "base"

module Pubid::Jis::Renderer
  class Explanation < Base
    def render_identifier(params)
      if params[:number].to_s.empty?
        "%<base>s/EXPL" % params
      else
        "%<base>s/EXPL %<number>s" % params
      end
    end
  end
end
