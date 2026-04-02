# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Nist
    module Components
      # IssueNumber component for NIST identifiers
      # Represents the issue/number designation (e.g., "No. 12" in "Vol. 6, No. 12")
      class IssueNumber < Lutaml::Model::Serializable
        attribute :number, :string

        # Short form rendering: "n12"
        # Long form rendering: "No. 12"
        def to_s(format = :short)
          case format
          when :long, :full
            "No. #{number}"
          when :short, :mr
            "n#{number}"
          else
            "n#{number}"
          end
        end
      end
    end
  end
end
