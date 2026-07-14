# frozen_string_literal: true

module Pubid
  module W3c
    module Identifiers
      # Bare-code W3C reference with no maturity token, e.g. "W3C 2dcontext",
      # "W3C 07-WebData". The default type; carries no `type_prefix`.
      class Standard < Identifier
      end
    end
  end
end
