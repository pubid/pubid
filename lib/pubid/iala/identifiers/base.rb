# frozen_string_literal: true

# Backward-compatible alias: IALA's base class used to be
# Pubid::Iala::Identifiers::Base. It is now Pubid::Iala::Identifier
# (defined in identifier.rb), which is loaded by the parent autoload.
require_relative "../identifier" unless defined?(Pubid::Iala::Identifier)

module Pubid
  module Iala
    module Identifiers
      Base = Pubid::Iala::Identifier
    end
  end
end
