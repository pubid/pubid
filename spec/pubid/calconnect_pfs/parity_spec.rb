# frozen_string_literal: true

# The CalConnect acceptance port's parity gate (pubid/pubid#706 §8): the
# compiled `calconnect_pfs` flavor must reproduce the coded `calconnect`
# flavor byte-for-byte over the flavor's whole corpus — every row of the
# pubid-testsuite payload (canonical hash, human and urn representations,
# the non-normalized aliases, the from_hash round trip) and every
# negative. Drift is a defect in the DEFINITION or the compiler, never a
# reason to relax an expectation here.

require "spec_helper"
require "pubid/conformance"

RSpec.describe "Pubid::CalconnectPfs parity with the coded Pubid::Calconnect" do
  corpus_repo = ENV.fetch("PUBID_TESTSUITE_PATH",
                          File.expand_path("../../../../pubid-testsuite", __dir__))
  corpus_dir = File.join(corpus_repo, "tests")
  corpus_present = File.directory?(File.join(corpus_dir, "calconnect"))
  before do
    skip "pubid-testsuite corpus absent" unless corpus_present
    Pubid.eager_load_flavors!
  end

  cases = corpus_present ? Pubid::Conformance::Corpus.cases("calconnect", corpus_dir) : []
  negatives = corpus_present ? Pubid::Conformance::Corpus.load_file(
    File.join(corpus_dir, "calconnect", "_negative.yaml"),
  ) : []

  # Every payload row: both flavors parse the human form, and the compiled
  # flavor reproduces the coded flavor's every surface byte-for-byte.
  cases.each do |test_case|
    input = test_case.representations.human

    it "agrees byte-for-byte with the coded flavor on #{test_case.id} (#{input.inspect})" do
      coded = Pubid::Calconnect.parse(input)
      pfs = Pubid::CalconnectPfs.parse(input)

      # Class-equivalent semantics: distinct classes, same shape.
      expect(pfs.class).to be < Pubid::Identifier
      expect(pfs.class).not_to eq(coded.class)

      expect(pfs.to_s).to eq(coded.to_s)
      expect(pfs.to_hash).to eq(coded.to_hash)
      # the corpus row's own canonical hash, both sides
      expect(Pubid::Conformance.plainify(pfs.to_hash)).to eq(test_case.identifier)
      expect(pfs.to_urn).to eq(coded.to_urn)
      expect(pfs.to_mr_string).to eq(coded.to_mr_string)
      expect(pfs.to_pubid_urn).to eq(coded.to_pubid_urn)
    end

    it "round-trips #{test_case.id} through its own from_hash" do
      pfs = Pubid::CalconnectPfs.parse(input)
      expect(Pubid::CalconnectPfs::Identifier.from_hash(pfs.to_hash)).to eq(pfs)
    end

    test_case.non_normalized_aliases.each do |alias_row|
      it "normalizes the alias #{alias_row.spelling.inspect} of #{test_case.id} like the coded flavor" do
        expect(Pubid::CalconnectPfs.parse(alias_row.spelling).to_s)
          .to eq(Pubid::Calconnect.parse(alias_row.spelling).to_s)
          .and eq(test_case.representations.human)
      end
    end
  end

  # Every negative: both flavors must reject with the same error class.
  negatives.each do |test_case|
    input = test_case.input
    it "rejects #{input.inspect} like the coded flavor" do
      expect { Pubid::Calconnect.parse(input) }
        .to raise_error(Pubid::Errors::ParseError)
      expect { Pubid::CalconnectPfs.parse(input) }
        .to raise_error(Pubid::Errors::ParseError)
    end
  end

  # The constructed faces beyond the corpus: every optional segment on and
  # off, and the internal-form flag.
  PARITY_FACES = [
    "CC 9101", "CC 9101:2024", "CC/CD 9101", "CC/CD 9101:2024",
    "CC/Adv 0707.1:2007", "CC/A 0812-1:2008", "CC/WD 51017:2024-07-23",
    "CC/R 9101:2024", "CC/S 9101:2024", "CC/FDS 9101:2024",
  ].freeze

  PARITY_FACES.each do |input|
    it "matches the coded flavor on the face #{input.inspect}, including the internal form" do
      coded = Pubid::Calconnect.parse(input)
      pfs = Pubid::CalconnectPfs.parse(input)

      expect(pfs.to_s).to eq(coded.to_s)
      expect(pfs.to_s(with_publisher: false)).to eq(coded.to_s(with_publisher: false))
      expect(pfs.to_hash).to eq(coded.to_hash)
    end
  end

  it "shares the input guards with the coded flavor" do
    [Pubid::Calconnect, Pubid::CalconnectPfs].each do |flavor|
      expect { flavor.parse(42) }
        .to raise_error(Pubid::Errors::InvalidInputError, Pubid::INPUT_NOT_A_STRING_MESSAGE)
      expect { flavor.parse("x" * (Pubid::MAX_INPUT_LENGTH + 1)) }
        .to raise_error(Pubid::Errors::InvalidInputError,
                        Pubid::INPUT_TOO_LONG_MESSAGE)
    end
  end

  it "never hijacks Pubid.parse — the coded flavor keeps routing calconnect" do
    expect(Pubid.parse("CC 18011:2018")).to be_a(Pubid::Calconnect::Identifier)
  end

  it "registers beside the coded flavor (coexistence, not cutover)" do
    expect(Pubid::Registry.registered?(:calconnect)).to be(true)
    expect(Pubid::Registry.registered?(:calconnect_pfs)).to be(true)
    expect(Pubid::CalconnectPfs::UrnGenerator.new(nil).urn_namespace).to eq("calconnect")
    expect(Pubid::PubidUrn.flavor_schema("calconnect_pfs")).not_to be_nil
    expect(Pubid::PubidUrn.flavor_schema("calconnect")).not_to be_nil
  end

  it "carries the scheme's composition surface for introspection" do
    # The module composition the definition binds (none for calconnect —
    # its port forced the compiler extensions, not the modules), and the
    # type the scheme declares.
    # a module-free flavor declares no composition surface
    expect(Pubid::CalconnectPfs.const_defined?(:MODULES)).to be(false)
    expect(Pubid::CalconnectPfs::Identifiers::Standard.type).to eq(
      key: :cc, web: :standard, title: "CalConnect Standard", short: "CC",
    )
  end
end
