# frozen_string_literal: true

module Pubid
  module Oiml
    module Components
      # Code component for OIML identifiers.
      #
      # Stays independent of Pubid::Components::Code because OIML uses
      # +number+ as the primary field (shared Code uses +value+). The
      # shape is otherwise compatible; a future rename of +number+ →
      # +value+ would let this become a subclass.
      class Code < Lutaml::Model::Serializable
        attribute :number, :string
        attribute :part, :string
        attribute :subpart, :string

        def to_s
          result = number.to_s
          result += "-#{part}" if part
          result += "-#{subpart}" if subpart
          result
        end

        def render(context: nil)
          to_s
        end
      end
    end
  end
end
