# frozen_string_literal: true

module Pubid
  module Iec
    module Identifier
      class SocietalTechnologyTrendReport < Base
        def_delegators "Pubid::Iec::Identifier::SocietalTechnologyTrendReport",
                       :type

        def self.type
          { key: :sttr, title: "Societal and Technology Trend Report",
            short: "Trend Report" }
        end

        def to_h(deep: true, add_type: true)
          result = super(deep: deep, add_type: false)
          result[:type] = "Trend Report" if add_type
          result
        end
      end
    end
  end
end
