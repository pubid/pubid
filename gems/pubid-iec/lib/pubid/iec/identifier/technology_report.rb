module Pubid::Iec
  module Identifier
    class TechnologyReport < Base
      def_delegators 'Pubid::Iec::Identifier::TechnologyReport', :type

      def self.type
        { key: :tec, title: "Technology Report", short: "Technology Report" }
      end

      def to_h(deep: true, add_type: true)
        result = super(deep: deep, add_type: false)
        result[:type] = "Technology Report" if add_type
        result
      end
    end
  end
end
