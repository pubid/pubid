# frozen_string_literal: true

module Pubid
  module Rendering
    module Publisher
      # Render publisher with optional copublishers
      # @param publisher [Components::Publisher, String] base publisher
      # @param copublishers [Array<Components::Publisher>, nil] optional copublisher list
      # @param options [Hash] rendering options
      # @return [String] formatted publisher string
      def render_publisher(publisher, copublishers = nil, **options)
        return "" unless publisher

        result = publisher.to_s

        if copublishers&.any?
          separator = options[:copublisher_separator] || "/"
          result += copublishers.map { |cp| "#{separator}#{cp}" }.join
        end

        result
      end
    end
  end
end
