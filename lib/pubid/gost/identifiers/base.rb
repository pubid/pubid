# frozen_string_literal: true

# Backward-compatible alias: GOST's base class is Pubid::Gost::Identifier
# (defined in identifier.rb), loaded by the parent autoload.
module Pubid
  module Gost
    module Identifiers
      Base = Pubid::Gost::Identifier
    end
  end
end
