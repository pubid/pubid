# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Sae
    module Components
      # Code component for SAE numbers
      # Handles numbers with optional letter suffix (e.g., "7904F", "2813G")
      class Code < Lutaml::Model::Serializable
        attribute :value, :string

        def to_s
          value.to_s
        end
      end
    end
  end
end
