module Pubid::Iec
  module Identifier
    class TechnologyReport < Base
      def_delegators 'Pubid::Iec::Identifier::TechnologyReport', :type

      def self.type
        { key: :tec, title: "Technology Report", short: "Technology Report" }
      end

      def to_h(deep: true)
        super(deep: deep).merge(type: "Technology Report")
      end
    end
  end
end
