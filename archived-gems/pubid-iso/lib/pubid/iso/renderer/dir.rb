require_relative "base"

module Pubid::Iso::Renderer
  class Dir < Base
    def render_identifier(params, _opts)
      res = if params.key?(:jtc_dir)
              ("%<publisher>s%<dirtype>s%<number>s DIR%<year>s%<edition>s" % params)
            else
              ("%<publisher>s DIR%<dirtype>s%<number>s%<year>s%<edition>s" % params)
            end

      if params.key?(:joint_document)
        joint_params = prerender_params(
          params[:joint_document].to_h(deep: false), {}
        )
        joint_params.default = ""
        res += (" + %<publisher>s%<dirtype>s%<number>s%<year>s" % joint_params)
      end

      res
    end

    def render_number(number, _opts, _params)
      " #{number}"
    end

    def render_dirtype(dirtype, _opts, _params)
      " #{dirtype}"
    end

    def render_edition(edition, _opts, _params)
      " #{edition[:publisher]}" + (edition[:year] ? ":#{edition[:year]}" : "")
    end
  end
end
