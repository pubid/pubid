# frozen_string_literal: true

module Pubid
  module Components
    # Locality marker (e.g. "all parts")
    #
    # Renders the human-readable phrase "(all parts)" and a URN
    # suffix that completes the locality segment.
    class Locality < Lutaml::Model::Serializable
      attribute :value, :string

      def render(context: nil)
        return "all" if context&.urn?

        "(all parts)"
      end
    end
  end
end
