# frozen_string_literal: true

require "lutaml/model"
require_relative "../rendering/context" if File.exist?(File.join(__dir__,
                                                                 "../../rendering/context.rb"))

module Pubid
  module Components
    # Resource type component (a set of defined resource types)
    class Type < Lutaml::Model::Serializable
      attribute :name, :string
      attribute :abbr, :string
      attribute :type_code, :string

      # Render type with optional context for flavor-specific separators and default handling
      #
      # @param context [RenderingContext] rendering context for flavor rules
      # @param has_prefix [Boolean] whether there's a prefix (stage or copublisher)
      # @return [String] rendered type string
      def to_s(context: nil, has_prefix: false)
        return "" unless abbr

        # Check if this type should be rendered (not the default)
        if context && !context.should_render_type?(abbr)
          return ""
        end

        if context
          sep = context.type_separator_for(has_prefix)
          sep == "" ? abbr : "#{sep}#{abbr}"
        else
          # Default behavior: space after prefix, slash otherwise
          has_prefix ? " #{abbr}" : "/#{abbr}"
        end
      end

      def render(context: nil)
        name.to_s
      end

      # Returns hash code for type component
      # @return [Integer] hash code
      # @note Memoized for performance
      def hash
        @hash ||= [type_code, abbr].compact.map(&:hash).hash
      end

      # Checks equality with another type component
      # @param other [Object] object to compare with
      # @return [Boolean] true if equal
      def eql?(other)
        return false unless other.is_a?(self.class)

        type_code == other.type_code && abbr == other.abbr
      end
    end
  end
end
