# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Nist
    module Components
      # NIST document code (series + number with optional revision)
      # Handles formats like:
      #   IR 73-101      - series IR, number 73-101
      #   SP 800-53r5    - series SP, number 800-53, revision r5
      #   TN 1234        - series TN, number 1234
      class Code < Lutaml::Model::Serializable
        attribute :series, :string           # IR, SP, TN, HB, FIPS, etc.
        attribute :number, :string           # Main number
        attribute :part, :string             # Part number after dash
        attribute :revision, :string         # Revision like r5, e2, etc.

        def initialize(series: nil, number: nil, part: nil, revision: nil)
          super()
          self.series = series
          self.number = number
          self.part = part
          self.revision = revision
        end

        def to_s
          result = series.to_s
          result += " #{number}"
          result += "-#{part}" if part
          result += revision if revision
          result
        end
      end
    end
  end
end