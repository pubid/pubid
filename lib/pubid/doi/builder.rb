# frozen_string_literal: true

module Pubid
  module Doi
    class Builder
      def self.build(parsed_data)
        new.build(parsed_data)
      end

      def build(data)
        Identifiers::Resource.new(
          prefix: "10.#{data[:prefix]}",
          suffix: data[:suffix].to_s,
        )
      end
    end
  end
end
