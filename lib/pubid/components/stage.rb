# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Components
    # Stage component (a set of defined stages)
    #
    # Human render: abbreviation with flavor-specific separator.
    # URN render: stage abbreviation alone (no separator).
    class Stage < Lutaml::Model::Serializable
      attribute :name, :string
      attribute :stage_code, :string
      attribute :harmonized_stages, :string, collection: true
      attribute :abbr, :string

      def to_s(context: nil, has_copublisher: false)
        return "" unless abbr

        if context
          sep = context.stage_separator_for(has_copublisher:)
          sep == "" ? abbr : "#{sep}#{abbr}"
        else
          has_copublisher ? " #{abbr}" : "/#{abbr}"
        end
      end

      def render(context: nil)
        return abbr.to_s if context&.urn?

        abbr.to_s
      end

      def hash
        @hash ||= [stage_code, abbr].compact.map(&:hash).hash
      end

      def eql?(other)
        return false unless other.is_a?(self.class)

        stage_code == other.stage_code && abbr == other.abbr
      end
    end
  end
end
