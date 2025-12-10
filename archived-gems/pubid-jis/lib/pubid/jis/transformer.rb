module Pubid::Jis
  class Transformer < Pubid::Core::Transformer
    rule(part: sequence(:part)) do |context|
      { part: context[:part].map(&:to_s).join("-") }
    end
  end
end
