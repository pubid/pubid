# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Jcgm
    module Components
      class Publisher < Lutaml::Model::Serializable
        attribute :publisher, :string

        def to_s
          publisher
        end

        # Alias for consistency
        alias_method :body, :publisher
      end
    end
  end
end
