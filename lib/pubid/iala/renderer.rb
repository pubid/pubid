# frozen_string_literal: true

module Pubid
  module Iala
    # Human-readable renderer for IALA identifiers.
    #
    # Produces strings like:
    #   "IALA S1070"
    #   "IALA S1070 Ed 2.0"
    #   "IALA R1016 Ed 2.0 (F)"
    class Renderer < ::Pubid::Renderers::Base
      def render(context: nil, **_opts)
        id = @id

        rendered = "#{id.publisher} #{id.type_letter}#{id.number}"
        rendered << " Ed #{id.edition}" if id.edition
        rendered << " (#{id.language})" if id.language
        rendered
      end
    end
  end
end
