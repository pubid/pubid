require_relative "base"

module Pubid::Bsi::Renderer
  class NationalAnnex < Base
    def render_identifier(params)
      "NA%<supplement>s to %<base>s" % params
    end
  end
end
