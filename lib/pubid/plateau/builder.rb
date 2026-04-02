# frozen_string_literal: true

module Pubid
  module Plateau
    class Builder
      def self.build(parsed)
        new.build(parsed)
      end

      def build(parsed)
        # Check for annex supplement first
        if parsed[:base_identifier] && parsed[:annex_letter]
          return build_annex(parsed)
        end

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
          number: parsed[:number].to_s.to_i,
        }

        params[:annex] = parsed[:annex].to_s.to_i if parsed[:annex]
        params[:edition] = parsed[:edition].to_s if parsed[:edition]

        klass.new(**params)
      end

      private

      def build_annex(parsed)
        # Recursively parse base identifier
        base = build(parsed[:base_identifier])

        Identifiers::Annex.new(
          base_identifier: base,
          letter: parsed[:annex_letter].to_s,
        )
      end
    end
  end
end
