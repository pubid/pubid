# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Bsi
    module Identifiers
      # National Annex identifier - wraps base document with NA amendments
      # Example: "NA+A1:2012 to BS EN 1993-5:2007"
      class NationalAnnex < Base
        attribute :identifiers, Base, polymorphic: true, collection: true

        def to_s
          result = "NA"
          
          # Render NA supplements first
          identifiers[1..-1].each do |supp|
            if supp.is_a?(Amendment)
              result += "+A#{supp.amendment_number}:#{supp.amendment_year}"
            end
          end
          
          result += " to "
          
          # Render base document
          result += identifiers.first.to_s
          
          result
        end
        
        def publisher
          "NA"
        end
      end
    end
  end
end
