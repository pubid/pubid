# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Asme
    module Components
      # Code component for ASME identifiers.
      #
      # Stays independent of Pubid::Components::Code because ASME uses
      # +designator+ (a flavor-specific letter prefix) plus +number+.
      class Code < Lutaml::Model::Serializable
        attribute :designator, :string
        attribute :number, :string

        def to_s
          render
        end

        def render(context: nil)
          "#{designator}#{number}"
        end
      end
    end
  end
end
