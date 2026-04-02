# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Nist
    module Components
      # Publisher component for NIST identifiers
      # Handles NIST and NBS publishers
      class Publisher < Lutaml::Model::Serializable
        attribute :publisher, :string

        def to_s
          publisher
        end

        # Alias for compatibility
        def body
          publisher
        end
      end
    end
  end
end
