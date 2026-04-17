module Pubid
  module Bsi
    module Renderer
      class Collection < Pubid::Core::Renderer::Base
        def render_identifier(params)
          "%<identifiers>s%<year>s%<supplement>s" % params
        end

        def render_supplement(supplement, _opts, _params)
          supplement.to_s
        end

        def render_identifiers(identifiers, _opts, _params)
          "#{identifiers.first}/" + identifiers[1..].map(&:number).join("/")
        end
      end
    end
  end
end
