# frozen_string_literal: true

# Backward-compatible alias: EASC's base class is Pubid::Easc::Identifier
# (defined in identifier.rb), loaded by the parent autoload.
module Pubid
  module Easc
    module Identifiers
      Base = Pubid::Easc::Identifier
    end
  end
end
