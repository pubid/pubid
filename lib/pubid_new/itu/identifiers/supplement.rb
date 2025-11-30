# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Itu
    module Identifiers
      # Supplement identifier (Suppl.)
      # Pattern: "ITU-T H Suppl. 1", "ITU-T E.156 Suppl. 2"
      class Supplement < Base
        attribute :base, Base, polymorphic: true
        attribute :number, :string

        def to_s
          result = base ? base.to_s : "#{publisher}-#{sector}"
          
          # Add series if no base
          if !base && series
            result += " #{series}"
          end
          
          result += " Suppl. #{number}"
          
          # Add date if present
          if date
            if date.month
              result += " (#{date.month}/#{date.year})"
            else
              result += " (#{date.year})"
            end
          end
          
          result
        end

        def ==(other)
          return false unless other.is_a?(Supplement)
          
          base == other.base &&
            number == other.number &&
            date == other.date
        end
      end
    end
  end
end