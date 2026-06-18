# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Sae
    module Components
      # Type component for SAE document types
      # AMS, AIR, ARP, AS, MA
      class Type < Lutaml::Model::Serializable
        attribute :abbr, :string

        def to_s
          render
        end

        def render(context: nil)
          abbr.to_s
        end
      end
    end
  end
end
