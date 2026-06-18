# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Components
    # Publisher ISO, IEC, etc.
    #
    # Human render: the publisher body (e.g. "ISO").
    # URN render: lowercase body (e.g. "iso") per RFC 5141-bis.
    class Publisher < Lutaml::Model::Serializable
      attribute :body, :string

      def to_s
        body
      end

      def render(context: nil)
        return body&.downcase if context&.urn?

        body
      end

      def copublished?
        false
      end

      def hash
        @hash ||= body.hash
      end

      def eql?(other)
        return false unless other.is_a?(self.class)

        body == other.body
      end
    end
  end
end
