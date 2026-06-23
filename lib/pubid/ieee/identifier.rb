# frozen_string_literal: true

module Pubid
  module Ieee
    # NOTE: intentionally does NOT `extend Pubid::IdentifierFacade`. IEEE's
    # `to_hash`/`from_hash` does not round-trip yet (e.g. `code`/`year` are
    # dropped on rebuild), so the facade would advertise a `from_hash` that
    # silently returns lossy objects — and a consumer's `instance_of?(module)`
    # validation can't catch it. Re-enable once IEEE serialization round-trips
    # cleanly. See identifier_facade.rb.
    module Identifier
      class << self
        def parse(input)
          Identifiers::Base.parse(input)
        end
      end
    end
  end
end
