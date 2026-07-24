# frozen_string_literal: true

module Pubid
  module Omg
    # Human-readable renderer for OMG specification identifiers.
    #
    # Produces:
    #   "OMG AMI4CCM 1.0"
    #   "OMG UML 2.5.1"
    #   "OMG CORBA"
    class Renderer < ::Pubid::Renderers::Base
      def render(**_opts)
        result = "OMG #{@id.acronym}"
        result += " #{@id.version}" if @id.version && !@id.version.empty?
        result
      end
    end
  end
end
