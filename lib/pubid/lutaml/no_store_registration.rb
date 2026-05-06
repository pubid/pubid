# frozen_string_literal: true

# Lutaml::Model::Store registers every Serializable instance in a global array
# on initialization via register_in_reference_store. For PubID, which parses
# tens of thousands of identifiers in test runs, this causes unbounded memory
# growth (~26 slots per parse, ~26GB for the full suite).
#
# PubID doesn't use Lutaml's reference resolution, so we disable it globally
# by overriding the method on Lutaml::Model::Serializable.
#
# Also provides default to_urn for all PubID identifier objects that resolve
# to their flavor's UrnGenerator class.
Lutaml::Model::Serializable.class_eval do
  def register_in_reference_store
    # no-op: PubID doesn't use Lutaml::Model reference resolution
  end

  def to_urn
    resolve_urn_generator.new(self).generate
  end

  private

  def resolve_urn_generator
    flavor = self.class.name.split("::")[1]
    Object.const_get("Pubid::#{flavor}::UrnGenerator")
  rescue NameError
    Pubid::UrnGenerator::Base
  end
end
