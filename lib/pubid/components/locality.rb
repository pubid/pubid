# frozen_string_literal: true
module Pubid
  module Components
    # Handles "all parts"
    class Locality < Lutaml::Model::Serializable
      attribute :value, :string
    end
  end
end
