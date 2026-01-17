require "lutaml/model"
# frozen_string_literal: true

module PubidNew
  module Components
    class Code < Lutaml::Model::Serializable
      attribute :value, :string

      def to_s
        value.to_s
      end
    end
  end
end
