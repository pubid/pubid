# frozen_string_literal: true

require "spec_helper"

Pubid.eager_load_flavors!

# Issue #803: the flavor dispatcher fails fast when the identifier's leading
# prefix resolves to EXACTLY ONE flavor — only that flavor's parser runs,
# instead of the owner plus the ~50-flavor exhaustive second pass. The
# condition is essential and is what these specs pin: an ambiguous prefix
# (a joint form, an umbrella's token, a PFS alias sharing its parent's
# tokens) and a string no prefix owns keep the full dispatch order.
RSpec.describe "Pubid.parse fail-fast flavor dispatch (#803)" do
  # Install the counting spy on every registered flavor's module-level
  # parse, recording into +counts+.
  def install_counting_spies(counts)
    spied = {}
    Pubid::Registry.flavor_names.each do |name|
      mod = Pubid::Registry.get(name)
      next if spied.key?(mod)

      spied[mod] = true
      allow(mod).to receive(:parse).and_wrap_original do |orig, *a, **k, &b|
        counts[mod] += 1
        orig.call(*a, **k, &b)
      end
    end
  end

  # A counting spy over every registered flavor's module-level parse.
  # Returns the per-module invocation counts recorded while the block runs;
  # only modules actually invoked appear as keys.
  def dispatch_counts
    counts = Hash.new(0)
    install_counting_spies(counts)
    yield
    counts
  end

  describe "a prefix that resolves to exactly one flavor" do
    it "invokes only the owning flavor's parser" do
      counts = dispatch_counts do
        expect(Pubid.parse("ISO 9001:2015").to_s).to eq("ISO 9001:2015")
      end

      expect(counts.keys).to eq([Pubid::Iso])
      expect(counts[Pubid::Iso]).to eq(1)
    end

    it "invokes only the owning flavor's parser when it rejects the input" do
      error = nil
      counts = dispatch_counts do
        Pubid.parse("3GPP")
      rescue Pubid::Errors::ParseError => e
        error = e
      end

      expect(error).to be_a(Pubid::Errors::ParseError)
      expect(counts.keys).to eq([Pubid::Tgpp])
      expect(counts[Pubid::Tgpp]).to eq(1)
    end

    it "reports the rejected input with the owning flavor's error" do
      direct =
        begin
          Pubid::Tgpp.parse("3GPP")
        rescue Pubid::Errors::ParseError => e
          e
        end

      expect { Pubid.parse("3GPP") }.to raise_error(
        Pubid::Errors::ParseError,
      ) { |e|
        expect(e.flavor).to eq("3gpp")
        expect(e.message).to eq(direct.message)
        expect(e.input).to eq(direct.input)
      }
    end

    it "still dispatches a normalizing sole-owner parse (OGC)" do
      counts = dispatch_counts { Pubid.parse("OGC 06-121r9") }

      expect(counts.keys).to eq([Pubid::Ogc])
    end
  end

  describe "an ambiguous prefix (more than one owner)" do
    it "routes a co-published identifier unchanged" do
      expect(Pubid.parse("ISO/IEC 2131:2013").to_s).to eq("ISO/IEC 2131:2013")
    end

    it "walks the full dispatch order when the owners reject the input" do
      error = nil
      counts = dispatch_counts do
        Pubid.parse("ISO/IEC @@ not an identifier @@")
      rescue Pubid::Errors::ParseError => e
        error = e
      end

      expect(error).to be_a(Pubid::Errors::ParseError)
      expect(counts[Pubid::Iec]).to eq(1)
      # >= 1, not == 1: flavors with a foreign-adoption lookup (GOST) call
      # the ISO parser again from inside their own parse.
      expect(counts[Pubid::Iso]).to be >= 1
      # The exhaustive second pass ran: far more than the two owners.
      expect(counts.keys.length).to be > 10
    end
  end

  describe "a string no prefix owns" do
    it "walks the full dispatch order unchanged" do
      error = nil
      counts = dispatch_counts do
        Pubid.parse("iec.60050")
      rescue Pubid::Errors::ParseError => e
        error = e
      end

      expect(error).to be_a(Pubid::Errors::ParseError)
      expect(counts.keys.length).to be > 10
      # The anything-goes flavors are still consulted — and still refused as
      # a fallback, which is why the string stays rejected.
      expect(counts[Pubid::Iana]).to eq(1)
      expect(counts[Pubid::Adobe]).to eq(1)
    end
  end
end
