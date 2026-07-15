# frozen_string_literal: true

module Pubid
  module Ecma
    # Turns the Parslet parse tree into a concrete identifier object. The class
    # is chosen by which number key the parser captured.
    class Builder
      def self.build(parsed_data)
        new.build(parsed_data)
      end

      def build(data)
        if data[:tr_number]
          Identifiers::TechnicalReport.new(number: data[:tr_number].to_s)
        elsif data[:mem_number]
          Identifiers::Memento.new(number: data[:mem_number].to_s)
        else
          build_standard(data)
        end
      end

      private

      def build_standard(data)
        attrs = { number: data[:number].to_s }
        attrs[:part] = data[:part].to_s if data[:part]
        Identifiers::Standard.new(**attrs)
      end
    end
  end
end
