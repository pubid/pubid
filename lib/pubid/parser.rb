# frozen_string_literal: true

module Pubid
  module Parser
    # A trailing "(all parts)" marks the reference as the whole document.
    # NIST's parse path strips it before preprocessing and carries the
    # marker into the tree (:all_parts) for the builder to wrap; the
    # shared Builder::Base reads the same marker for every other flavor.
    ALL_PARTS_SUFFIX = "(all parts)".freeze
  end
end
