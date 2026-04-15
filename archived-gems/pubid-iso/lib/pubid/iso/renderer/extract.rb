require_relative "base"

module Pubid
  module Iso
    module Renderer
      class Extract < Supplement
        def render_identifier(params, _opts)
          "/Ext%<number>s%<year>s" % params
        end
      end
    end
  end
end
