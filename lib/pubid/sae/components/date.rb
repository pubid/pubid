# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Sae
    module Components
      # The edition date of an SAE document.
      #
      # SAE dates a J report by year and month: its edition code is
      # +J3016_202104+, the April 2021 edition. A reference may state the
      # year alone (+SAE J3016:2021+); the month is then nil, and nil is a
      # wildcard under +===+, so the year-only reference matches every
      # edition of that year.
      class Date < Lutaml::Model::Serializable
        include ::Pubid::SubsetMatch

        attribute :year, :integer
        attribute :month, :integer

        def present?
          !year.nil?
        end

        def to_s
          render
        end

        # +202104+ with a month (SAE's edition code), +2021+ without.
        def render(context: nil)
          return year.to_s unless month

          format("%<year>04d%<month>02d", year: year, month: month)
        end
      end
    end
  end
end
