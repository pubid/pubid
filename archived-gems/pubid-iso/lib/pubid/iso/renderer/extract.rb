require_relative "base"

module Pubid::Iso::Renderer
  class Extract < Supplement
    def render_identifier(params, _opts)
      "/Ext%<number>s%<year>s" % params
    end
  end
end
