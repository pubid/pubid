module Pubid::Iec
  module Identifier
    class TechnologyAndMarketOutlookPaper < Base
      def_delegators 'Pubid::Iec::Identifier::TechnologyAndMarketOutlookPaper', :type

      def self.type
        { key: :tmop, title: "Technology and Market Outlook Paper", short: "Technology and Market Outlook Paper" }
      end

      def to_h(deep: false)
        super.merge(type: "Technology and Market Outlook Paper")
      end
    end
  end
end
