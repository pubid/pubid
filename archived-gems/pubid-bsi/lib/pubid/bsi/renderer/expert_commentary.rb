require_relative "base"

module Pubid
  module Bsi
    module Renderer
      class ExpertCommentary < Base
        def render_identifier(params)
          "%<base>s ExComm" % params
        end
      end
    end
  end
end
