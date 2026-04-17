module Pubid
  module Cen
    module Renderer
      class Base < Pubid::Core::Renderer::Base
        def render_identifier(params)
          return "%<publisher>s %<adopted>s%<supplements>s" % params unless params[:adopted].to_s.empty?

          "%<stage>s%<publisher>s%<type>s %<number>s%<part>s%<year>s%<supplements>s" % params
        end

        def render_type(_type, _opts, _params)
          ""
        end

        def render_part(part, _opts, _params)
          return "-#{part.join('-')}" if part.is_a?(Array)

          "-#{part}"
        end

        def sort_supplements(supplements)
          supplements.sort_by { |a| (a.year * 100) + a.number.to_i }
        end

        def render_supplements(supplements, _opts, _params)
          sort_supplements(supplements).join
        end
      end
    end
  end
end
