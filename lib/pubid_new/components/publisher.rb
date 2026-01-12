# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Components
    # Publisher ISO, IEC, etc.
    class Publisher < Lutaml::Model::Serializable
      attribute :body, :string

      def to_s
        body
      end
    end
  end
end
