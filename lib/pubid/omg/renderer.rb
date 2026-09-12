# frozen_string_literal: true

module Pubid
  module Omg
    # Human-readable renderer for OMG specification identifiers.
    #
    # Produces:
    #   "OMG AMI4CCM 1.0"
    #   "OMG UML 2.5.1"
    #   "OMG UML 2.1.1 Superstructure"
    #   "OMG CORBA"
    #
    # The document part always prints behind a space. OMG writes it behind
    # either a space or a slash, and the parser takes both, so normalizing
    # here is what keeps the two spellings of one document equal.
    class Renderer < ::Pubid::Renderers::Base
      def render(**_opts)
        result = "OMG #{@id.acronym}"
        result += " #{@id.version}" if present?(@id.version)
        result += " #{@id.part}" if present?(@id.part)
        result
      end

      private

      def present?(value)
        value && !value.empty?
      end
    end
  end
end
