module Pubid::Iec
  module Identifier
    class TechnologyAndMarketOutlookPaper < Base
      def_delegators 'Pubid::Iec::Identifier::TechnologyAndMarketOutlookPaper', :type

      def self.type
        { key: :tmop, title: "Technology and Market Outlook Paper", short: "Technology and Market Outlook Paper" }
      end

      def to_h(deep: true, add_type: true)
        result = super(deep: deep, add_type: false)
        result[:type] = "Technology and Market Outlook Paper" if add_type
        result
      end
    end
  end
end
