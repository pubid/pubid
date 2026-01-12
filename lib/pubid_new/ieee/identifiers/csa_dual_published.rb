# frozen_string_literal: true

require "lutaml/model"
require_relative "base"

module PubidNew
  module Ieee
    module Identifiers
      # CSA dual published identifier
      # Represents IEEE/CSA dual published standards
      # Example: IEEE Std 844.1-2017/CSA C22.2 No. 293.1-17
      class CsaDualPublished < Lutaml::Model::Serializable
        attribute :ieee_identifier, Base
        attribute :csa_portion, :string

        def to_s
          "#{ieee_identifier}/CSA #{csa_portion}"
        end

        def self.parse(string)
          Base.parse(string)
        end
      end
    end
  end
end
