module Pubid::Iec
  module Identifier
    class WritePaper < Base
      def_delegators 'Pubid::Iec::Identifier::WritePaper', :type

      def self.type
        { key: :wp, title: "Write Paper", short: "White Paper" }
      end

      def to_h(deep: true)
        super(deep: deep).merge(type: "White Paper")
      end
    end
  end
end
