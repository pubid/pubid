# frozen_string_literal: true

module Pubid
  module Amca
    module Identifiers
      # Interpretation identifier for ACMA interpretations
      # Examples:
      # - AMCA 99 JW Interp
      # - AMCA 204 – 1
      # - ANSI/AMCA 204 Interp
      class Interpretation < Base
        attr_reader :interpretation_code

        def initialize(code:, year: nil, copublisher: nil, suffix: nil,
reaffirmed: nil, interpretation_code: nil)
          @code = Components::Code.new(value: code.to_s)
          @year = Components::Date.new(year: year.to_s) if year
          @copublisher = copublisher
          @suffix = suffix
          @reaffirmed = reaffirmed
          @interpretation_code = interpretation_code
        end

        def self.type
          { key: :interpretation, title: "Interpretation", short: "Interp" }
        end

        def type
          Interpretation.type
        end

        # @return [String] the rendered interpretation identifier
        def to_s
          parts = []
          parts << @copublisher if @copublisher
          parts << @code.to_s

          if @interpretation_code
            parts << "– #{@interpretation_code}"
          elsif @year
            parts << "-#{@year}"
          end

          parts << " #{@suffix}" if @suffix

          parts.join(" ").squeeze(" ")
        end
      end
    end
  end
end
