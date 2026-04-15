require_relative "base"

module Pubid
  module Iso
    module Renderer
      class Guide < Base
        def render_identifier(params, opts)
          if opts[:language] == :french
            "Guide %<publisher>s%<stage>s %<number>s%<part>s%<iteration>s%<year>s%<amendments>s%<corrigendums>s%<edition>s" % params
          elsif opts[:language] == :russian
            "Руководство %<publisher>s%<stage>s %<number>s%<part>s%<iteration>s%<year>s%<amendments>s%<corrigendums>s%<edition>s" % params
          elsif params[:stage].is_a?(Pubid::Core::TypedStage)
            "%<publisher>s%<stage>s %<number>s%<part>s%<iteration>s%<year>s%<amendments>s%<corrigendums>s%<edition>s" % params
          else
            "%<publisher>s%<stage>s Guide %<number>s%<part>s%<iteration>s%<year>s%<amendments>s%<corrigendums>s%<edition>s" % params
          end
        end
      end
    end
  end
end
