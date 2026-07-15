# frozen_string_literal: true

require "spec_helper"

# Populate the registry at collection time so the per-flavor examples below are
# generated for every registered flavor (flavor_names is empty until loaded).
Pubid.eager_load_flavors!

# Cross-flavor contract for the uniform `Pubid::<Flavor>::Identifier.parse`
# class method. relaton (and any consumer holding a flavor's Identifier class)
# relies on being able to call `<Flavor>::Identifier.parse(string)` uniformly,
# in addition to the module-level `Pubid::<Flavor>.parse`. This spec locks that
# invariant so a newly-added flavor cannot silently omit the class method.
RSpec.describe "Flavor Identifier.parse API" do
  describe "uniform contract across every registered flavor" do
    Pubid::Registry.flavor_names.each do |flavor_name|
      context flavor_name do
        let(:mod) { Pubid::Registry.get(flavor_name) }
        let(:identifier_class) { mod.const_get(:Identifier) }

        it "exposes an Identifier class" do
          expect(identifier_class).to be_a(Class)
          expect(identifier_class).to be < Pubid::Identifier
        end

        it "responds to Identifier.parse" do
          expect(identifier_class).to respond_to(:parse)
        end

        it "accepts exactly one required positional argument" do
          required = identifier_class.method(:parse).parameters
            .count { |type, _name| type == :req }
          expect(required).to eq(1)
        end
      end
    end
  end
end
