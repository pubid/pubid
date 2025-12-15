# frozen_string_literal: true

module PubidNew
  module Astm
    module Identifiers
      class Manual < Base
        attribute :edition, :string          # 9TH, 2ND
        attribute :supplement, :boolean      # -SUP-
        attribute :tp_designation, :string   # TP for technical publications

        def to_s
          parts = []
          parts << publisher if publisher
          parts << "MNL"
          parts << "TP" if tp_designation
          parts << code.number if code

          result = parts.join

          # Edition with dash separator
          result += "-#{edition}" if edition

          # Add separator after publisher
          if publisher
            # Insert space after publisher
            result = "#{publisher} #{result[publisher.length..-1]}"
          end

          # Add supplement if present
          result += "-SUP" if supplement

          # Add format suffix (already has dash from builder)
          result += format_suffix if format_suffix

          result
        end
      end
    end
  end
end