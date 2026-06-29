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
        # Free-form trailing suffix glued to the code, e.g. "sup", "A",
        # "erratum", "GUM 1", "ISO3930". Preserved verbatim for round-trip.
        attribute :suffix, :string
        # When true the suffix is space-separated ("D 1 Brochure") rather than
        # the default dash ("R 60-sup").
        attribute :space_suffix, :boolean, default: false

        def to_s
          result = number.to_s
          result += "-#{part}" if part
          result += "-#{subpart}" if subpart
          result += "#{space_suffix ? ' ' : '-'}#{suffix}" if suffix
          result
        end

        def render(context: nil)
          to_s
        end
      end
    end
  end
end
