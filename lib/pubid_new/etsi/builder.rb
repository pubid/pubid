module PubidNew
  module Etsi
    class Builder
      attr_reader :scheme_class

      def initialize(scheme_class)
        @scheme_class = scheme_class
      end

      def build(parsed)
        params = {
          type: parsed[:type].to_s,
          number: parsed[:number].to_s,
          date: parsed[:date].to_s
        }

        # Handle parts - can be array or single value
        # Part comes with dash like "-1", need to remove it
        if parsed[:part]
          parts = parsed[:part].is_a?(Array) ? parsed[:part] : [parsed[:part]]
          params[:part] = parts.map { |p| p.to_s.sub(/^-/, "") }
        end

        # Handle version or edition (mutually exclusive)
        params[:version] = parsed[:version].to_s if parsed[:version]
        params[:edition] = parsed[:edition].to_s if parsed[:edition]

        # Handle supplements
        params[:amendment] = parsed[:amendment].to_s if parsed[:amendment]
        params[:corrigendum] = parsed[:corrigendum].to_s if parsed[:corrigendum]

        scheme_class.new(**params)
      end
    end
  end
end