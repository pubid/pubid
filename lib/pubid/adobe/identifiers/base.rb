# frozen_string_literal: true

module Pubid
  module Adobe
    module Identifiers
      # Backward-compatible alias: Adobe's base class is
      # Pubid::Adobe::Identifier (defined in identifier.rb), loaded by
      # the parent autoload. Identifiers::Base points back to it so the
      # `Identifiers::*` namespace reads naturally.
      Base = Pubid::Adobe::Identifier
    end
  end
end
