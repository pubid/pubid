# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Sae
    module Components
      # Date component for SAE standards
      # SAE uses year only (e.g., 2024, 2022)
      class Date < Lutaml::Model::Serializable
        attribute :year, :integer

        def to_s
          year.to_s
        end
      end
    end
  end
end
