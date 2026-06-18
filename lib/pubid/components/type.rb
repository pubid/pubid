# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Components
    # Resource type component (a set of defined resource types)
    #
    # Human render: abbreviation with flavor-specific separator.
    # URN render: type code (e.g. "tr", "ts") per RFC 5141-bis.
    class Type < Lutaml::Model::Serializable
      attribute :name, :string
      attribute :abbr, :string
      attribute :type_code, :string

      def to_s(context: nil, has_prefix: false)
        return "" unless abbr

        if context && !context.should_render_type?(abbr)
          return ""
        end

        if context
          sep = context.type_separator_for(has_prefix)
          sep == "" ? abbr : "#{sep}#{abbr}"
        else
          has_prefix ? " #{abbr}" : "/#{abbr}"
        end
      end

      def render(context: nil)
        return type_code.to_s if context&.urn? && type_code

        name.to_s
      end

      def hash
        @hash ||= [type_code, abbr].compact.map(&:hash).hash
      end

      def eql?(other)
        return false unless other.is_a?(self.class)

        type_code == other.type_code && abbr == other.abbr
      end
    end
  end
end
