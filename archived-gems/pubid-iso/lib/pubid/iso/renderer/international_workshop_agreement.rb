require_relative "base"

module Pubid
  module Iso
    module Renderer
      class InternationalWorkshopAgreement < Base
        TYPE = "IWA".freeze

        def omit_post_publisher_symbol?(_typed_stage, _stage, _opts)
          # always need post publisher symbol, because we always have to add "TR"
          false
        end

        def render_identifier(params, opts)
          stage = if params.key?(:stage)
                    postrender_stage(params[:stage], opts,
                                     params)
                  else
                    ""
                  end
          "#{stage}#{render_type_prefix(params,
                                        opts)} %<number>s%<part>s%<iteration>s%<year>s%<amendments>s%<corrigendums>s%<addendum>s%<edition>s" % params
        end
      end
    end
  end
end
