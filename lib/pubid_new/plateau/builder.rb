# frozen_string_literal: true

require_relative "identifiers/handbook"
require_relative "identifiers/technical_report"

module PubidNew
  module Plateau
    class Builder
      def self.build(parsed)
        new.build(parsed)
      end

      def build(parsed)
        # Determine which class to use based on type
        klass = case parsed[:type].to_s
                when "Handbook"
                  Identifiers::Handbook
                when "Technical Report"
                  Identifiers::TechnicalReport
                else
                  raise "Unknown PLATEAU type: #{parsed[:type]}"
                end

        # Build parameters common to all types
        params = {
          number: parsed[:number].to_s.to_i
        }

        params[:annex] = parsed[:annex].to_s.to_i if parsed[:annex]
        params[:edition] = parsed[:edition].to_s if parsed[:edition]

        klass.new(**params)
      end
    end
  end
end