# frozen_string_literal: true

require "spec_helper"

# The pubid-scheme URN contract (issue #656), for every registered flavor.
#
# The pubid-scheme URN is the slug source for relaton (relaton/relaton#441),
# so over the whole pass-fixture corpus of a flavor it must:
#   (a) emit, for every identifier;
#   (b) round-trip: Pubid.parse_urn(id.to_pubid_urn).to_hash == id.to_hash;
#   (c) be injective: two different hashes never share a URN;
#   (d) be path-safe: only [A-Za-z0-9._~,()-] and ":", no empty segment.
#
# The official URN (#to_urn) is NOT under this contract: it may be lossy.
#
# The table is complete (issue #670): every flavor carries a schema and
# passes, so PENDING is empty. A flavor added tomorrow lands with its
# schema, its docs/URN-SCHEMES.adoc section and its corpus row in the same
# change; until then its example runs as `pending` (list it here), and the
# red "expected pending to fail" is the signal to delete the entry.
module PubidUrnContract
  extend FixtureFileHelper

  FIXTURE_ROOT = File.expand_path("../fixtures", __dir__)
  DESIGN_DOC = File.expand_path("../../docs/URN-SCHEMES.adoc", __dir__)
  PATH_SAFE = /\Aurn:pubid:[A-Za-z0-9._~,()\-:]+\z/

  # flavor registry name => fixture directory, where the two differ.
  FIXTURE_DIRS = { "3gpp" => "tgpp" }.freeze

  # Flavors with no fixture corpus (adobe and sae have no pass/ files):
  # the literals stand in for one, so the contract exercises their schema
  # all the same.
  LITERALS = {
    "adobe" => ["Adobe TN 5014", "Adobe Technical Note 5902", "adobe-glyph-list",
                "adobe-japan1-7", "adobe-postscript-3"],
    "sae" => ["SAE J3016_202104", "SAE J3016", "SAE AS6108A", "SAE ARP5548",
              "SAE AMS2750F"],
  }.freeze

  PENDING = [].freeze

  module_function

  # One flavor name for each module: "cen" is an alias of "cen_cenelec".
  def flavors
    Pubid.eager_load_flavors!
    Pubid::Registry.flavor_names.sort
      .group_by { |name| Pubid::Registry.get(name) }
      .values.map { |names| names.max_by(&:length) }
  end

  def inputs(flavor)
    return LITERALS.fetch(flavor) if LITERALS.key?(flavor) &&
                                     Dir.glob(File.join(FIXTURE_ROOT, flavor,
                                                        "**", "pass", "*.txt")).empty?

    dir = File.join(FIXTURE_ROOT, FIXTURE_DIRS.fetch(flavor, flavor))
    Dir.glob(File.join(dir, "**", "pass", "*.txt")).flat_map do |file|
      read_pass_fixture_entries(file).map(&:first)
    end.uniq
  end

  def path_safe?(urn)
    PATH_SAFE.match?(urn) && !urn.include?("::") && !urn.end_with?(":")
  end

  # @return [Array<String>] the failures over the corpus of +flavor+
  def failures(flavor)
    mod = Pubid::Registry.get(flavor)
    seen = {}
    inputs(flavor).each_with_object([]) do |input, failures|
      failure = check(mod, input, seen)
      failures << failure if failure
      # A pending flavor fails on its first id; the rest is no news.
      break failures if failure && PENDING.include?(flavor)
    end
  end

  # A fixture that does not parse is the fixture spec's concern, not this
  # contract's. Two classes mean "does not parse": the contract's own
  # ParseError, and the engine's BindError, which some grammars still leak
  # (recorded in docs/URN-SCHEMES.adoc). Any other error from parse — a
  # builder crash — is NOT skipped: it is reported as a failure here.
  # Resolved when the rescue runs: the engine loads with the first parse.
  def parse_failures
    [Pubid::Errors::ParseError,
     (::Parsanol::PARG::BindError if defined?(::Parsanol::PARG::BindError))]
      .compact
  end

  def parsed(mod, input)
    mod.parse(input)
  rescue *parse_failures
    nil
  end

  def check(mod, input, seen)
    id = parsed(mod, input) or return
    hash = id.to_hash
    urn = id.to_pubid_urn
    return "#{input}: not path-safe: #{urn}" unless path_safe?(urn)

    back = Pubid.parse_urn(urn).to_hash
    return "#{input}: #{urn} -> #{back.inspect}" unless back == hash
    return "#{input}: collision on #{urn}" if seen.fetch(urn, hash) != hash

    seen[urn] = hash
    nil
  rescue StandardError => e
    "#{input}: #{e.class}: #{e.message[0, 120]}"
  end
end

RSpec.describe "pubid-scheme URN contract" do
  it "has a pubid-scheme section in the design doc for every flavor" do
    doc = File.read(PubidUrnContract::DESIGN_DOC)
    missing = PubidUrnContract.flavors.reject do |flavor|
      doc.include?("[[urn-#{flavor}]]")
    end
    expect(missing).to be_empty
  end

  it "lists no unknown flavor as pending" do
    expect(PubidUrnContract::PENDING - PubidUrnContract.flavors).to be_empty
  end

  PubidUrnContract.flavors.each do |flavor|
    describe flavor do
      before do
        if PubidUrnContract::PENDING.include?(flavor)
          pending("pubid-scheme schema not landed")
        end
      end

      it "emits, round-trips, is injective and path-safe over the corpus" do
        expect(PubidUrnContract.inputs(flavor)).not_to be_empty

        failures = PubidUrnContract.failures(flavor)
        expect(failures).to be_empty,
                            "#{failures.size} failures:\n" \
                            "#{failures.first(20).join("\n")}"
      end
    end
  end
end
