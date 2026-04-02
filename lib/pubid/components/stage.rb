# frozen_string_literal: true

require "lutaml/model"
require_relative "../rendering/context" if File.exist?(File.join(__dir__,
                                                                 "../../rendering/context.rb"))

module Pubid
  module Components
    # Stage component (a set of defined stages)
    class Stage < Lutaml::Model::Serializable
      attribute :name, :string
      attribute :stage_code, :string
      attribute :harmonized_stages, :string, collection: true
      attribute :abbr, :string

      # Render stage with optional context for flavor-specific separators
      #
      # @param context [RenderingContext] rendering context for flavor rules
      # @param has_copublisher [Boolean] whether identifier has copublisher
      # @return [String] rendered stage string
      def to_s(context: nil, has_copublisher: false)
        return "" unless abbr

        if context
          sep = context.stage_separator_for(has_copublisher:)
          sep == "" ? abbr : "#{sep}#{abbr}"
        else
          # Default behavior: space after copublisher, slash otherwise
          has_copublisher ? " #{abbr}" : "/#{abbr}"
        end
      end

      # Returns hash code for stage component
      # @return [Integer] hash code
      # @note Memoized for performance
      def hash
        @hash ||= [stage_code, abbr].compact.map(&:hash).hash
      end

      # Checks equality with another stage component
      # @param other [Object] object to compare with
      # @return [Boolean] true if equal
      def eql?(other)
        return false unless other.is_a?(self.class)

        stage_code == other.stage_code && abbr == other.abbr
      end
    end
  end
end
