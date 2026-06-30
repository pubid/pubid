# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Etsi
    module Components
      # Represents an ETSI version string
      # Format: V1.2.3, V2.0.0, or ed.1
      class Version < Lutaml::Model::Serializable
        attribute :version, :string # e.g., "1.1.1", "2.0.0", "1"
        attribute :is_edition, :boolean, default: -> {
          false
        } # true for ed.N format

        # Args are optional and assigned via lutaml setters (with `super()`) so
        # the component's attributes are tracked and round-trip through
        # to_hash/from_hash — lutaml deserializes by calling `.new` with no args
        # and then assigning attributes.
        def initialize(version: nil, is_edition: false, **opts)
          super(**opts)
          self.version = version
          self.is_edition = is_edition
        end

        def to_s
          if is_edition
            "ed.#{version}"
          else
            "V#{version}"
          end
        end

        def ==(other)
          return false unless other.is_a?(Version)

          version == other.version && is_edition == other.is_edition
        end
      end
    end
  end
end
