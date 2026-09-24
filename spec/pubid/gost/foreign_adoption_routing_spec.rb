# frozen_string_literal: true

require "spec_helper"

# The flavor that parses a foreign adoption ("GOST 1437-2024 (ASTM
# D129-18)") must not depend on which flavor module the host application
# happened to load first. Two structural guarantees keep it that way:
# routing goes through the registered prefix index (longest single-owner
# prefix first, sorted fallback), and Registry.flavors is a key-sorted
# frozen view - registration (= module load) order is not observable.
RSpec.describe "Pubid::Gost foreign adoption routing" do
  it "routes by owning prefix" do
    adopted = Pubid::Gost
      .parse("GOST 1437-2024 (ASTM D129-18)").adopted_identifiers.first
    expect(adopted).to be_a(Pubid::Astm::Identifiers::Standard)
    expect(adopted.to_s).to eq("ASTM D129-18")
  end

  it "falls back to a ForeignReference for an unregistered owner" do
    adopted = Pubid::Gost
      .parse("ГОСТ 34853-2022 (OECD 460:2017)").adopted_identifiers.first
    expect(adopted).to be_a(Pubid::Gost::Identifiers::ForeignReference)
  end

  it "routes slash adoptions through the owning flavor" do
    adopted = Pubid::Gost.parse("ГОСТ 31610.18-2016/IEC 60079-18:2014").adopted
    expect(adopted).to be_a(Pubid::Iec::Identifier)
  end

  # "ISO/TR 25901-1:2016" attaches its type token to the publisher with a
  # slash, not a space. `prefix_owner` used to require a literal space after
  # a registered prefix, so this form matched no owner and fell through to
  # the exhaustive alphabetical-fallback loop across every registered
  # flavor. There, Pubid::Iec's grammar ALSO accepts the bare string (as its
  # own identifier, not an ISO one) and renders it "ISO TR ..." (space) -
  # wrong. Pubid::Bsi also accepts it, correctly delegating to ISO, and
  # ordinarily wins the race by sorting before "iec" - which is exactly why
  # the wrong render only showed up rarely, under full-suite load. Routing
  # this by prefix instead of by chance removes the race entirely.
  it "routes a slash-attached type prefix (ISO/TR) directly to its owner" do
    adopted = Pubid::Gost
      .parse("ГОСТ Р 58904-2020/ISO/TR 25901-1:2016").adopted
    expect(adopted).to be_a(Pubid::Iso::Identifiers::TechnicalReport)
    expect(adopted.to_s).to eq("ISO/TR 25901-1:2016")
  end

  it "routes ISO/TR even when bsi (the usual race winner) is unavailable" do
    # Proves the fix is prefix routing, not a lucky alphabetical race: with
    # "bsi" removed from the registry, the old fallback-loop behavior would
    # have let "iec" claim the string instead.
    Pubid::Registry.unregister(:bsi)
    adopted = Pubid::Gost
      .parse("ГОСТ Р 58904-2020/ISO/TR 25901-1:2016").adopted
    expect(adopted).to be_a(Pubid::Iso::Identifiers::TechnicalReport)
    expect(adopted.to_s).to eq("ISO/TR 25901-1:2016")
  ensure
    Pubid::Registry.register(:bsi, Pubid::Bsi)
  end

  it "routes a sibling slash-attached type prefix (ISO/TS)" do
    adopted = Pubid::Gost
      .parse("ГОСТ Р 71039-2023/ISO/TS 10303-1:2014").adopted
    expect(adopted).to be_a(Pubid::Iso::Identifiers::TechnicalSpecification)
    expect(adopted.to_s).to eq("ISO/TS 10303-1:2014")
  end

  describe "Pubid::Registry flavor view" do
    after { Pubid::Registry.unregister(:zz_probe) }

    it "hides registration order behind a sorted frozen view" do
      # A late registration (hosts autoload flavors in any order) must not
      # shift any consumer's iteration: the view stays key-sorted, and the
      # raw table is not public mutable state. The probe is unregistered
      # afterwards: registry-driven specs enumerate every flavor.
      Pubid::Registry.register(:zz_probe, Pubid::Astm)
      names = Pubid::Registry.flavors.keys
      expect(names).to eq(names.sort)
      expect(names.last).to eq("zz_probe")
      expect(Pubid::Registry.flavors).to be_frozen
      expect { Pubid::Registry.flavors[:hack] = Pubid::Astm }
        .to raise_error(FrozenError)
    end
  end
end
