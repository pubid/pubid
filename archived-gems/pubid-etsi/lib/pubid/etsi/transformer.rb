module Pubid
  module Etsi
    class Transformer < Pubid::Core::Transformer
      def initialize
        super

        # Transform part arrays to dash-separated strings
        rule(part: sequence(:parts)) do |context|
          { part: context[:parts].join("-") }
        end
      end
    end
  end
end
