module Pubid
  module Jis
    class Transformer < Pubid::Core::Transformer
      rule(part: sequence(:part)) do |context|
        { part: context[:part].join("-") }
      end
    end
  end
end
