require_relative "base"

module Pubid
  module Bsi
    module Renderer
      class NationalAnnex < Base
        def render_identifier(params)
          "NA%<supplement>s to %<base>s" % params
        end
      end
    end
  end
end
