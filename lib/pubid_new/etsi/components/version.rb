# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Etsi
    module Components
      # Represents an ETSI version string
      # Format: V1.2.3, V2.0.0, or ed.1
      class Version < Lutaml::Model::Serializable
        attribute :version, :string  # e.g., "1.1.1", "2.0.0", "1"
        attribute :is_edition, :boolean, default: -> { false }  # true for ed.N format

        def initialize(version:, is_edition: false)
          @version = version
          @is_edition = is_edition
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