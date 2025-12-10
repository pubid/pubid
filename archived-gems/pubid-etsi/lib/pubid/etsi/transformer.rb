module Pubid::Etsi
  class Transformer < Pubid::Core::Transformer
    def initialize
      super

      # Transform part arrays to dash-separated strings
      rule(part: sequence(:parts)) do |context|
        { part: context[:parts].map(&:to_s).join("-") }
      end
    end
  end
end
