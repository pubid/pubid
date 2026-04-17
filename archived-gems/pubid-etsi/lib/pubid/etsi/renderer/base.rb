module Pubid
  module Etsi
    module Renderer
      class Base < Pubid::Core::Renderer::Base
        TYPE = "".freeze

        def render_identifier(params)
          "%<publisher>s %<type>s %<number>s%<part>s%<amendment>s%<corrigendum>s%<version>s%<edition>s%<published>s" % params
        end

        def render_version(version, _opts, _params)
          " V#{version}"
        end

        def render_published(published, _opts, _params)
          " (#{published})"
        end

        def render_edition(edition, _opts, _params)
          " ed.#{edition}"
        end

        def render_part(part, _opts, _params)
          if part.is_a?(Array)
            "-#{part.join('-')}"
          else
            "-#{part}"
          end
        end

        def render_amendment(amendment, _opts, _params)
          "/A#{amendment[:number]}"
        end

        def render_corrigendum(corrigendum, _opts, _params)
          "/C#{corrigendum[:number]}"
        end
      end
    end
  end
end
