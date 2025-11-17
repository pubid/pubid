module PubidNew
  module Plateau
    class Builder
      attr_reader :scheme_class

      def initialize(scheme_class)
        @scheme_class = scheme_class
      end

      def build(parsed)
        params = {
          type: parsed[:type].to_s,
          number: parsed[:number].to_s.to_i
        }

        params[:annex] = parsed[:annex].to_s.to_i if parsed[:annex]
        params[:edition] = parsed[:edition].to_s if parsed[:edition]

        scheme_class.new(**params)
      end
    end
  end
end