# frozen_string_literal: true

require "spec_helper"

# Populate the registry at collection time so one example is generated for
# every registered flavor (flavor_names is empty until loaded).
Pubid.eager_load_flavors!

# The fixture sample the contract below runs over, per registered flavor.
module WithPublisherContractSample
  ROOT = File.expand_path("../fixtures", __dir__)

  # Registry name => fixture directory, where the two differ.
  DIRS = { "3gpp" => "tgpp", "cen" => "cen_cenelec" }.freeze

  # Flavors with no pass fixtures, and a reference for each.
  REFS = {
    "adobe" => ["Adobe TN 5014"],
    "sae" => ["SAE J300:2019"],
  }.freeze

  # Entries read from each pass file. The full corpus is ~100,000 ids and
  # takes minutes; an evenly spaced sample reaches every file, so every
  # identifier shape the classifier separated is tried.
  PER_FILE = 20

  extend FixtureFileHelper

  def self.inputs(flavor)
    sampled = pass_files(flavor).flat_map do |file|
      entries = read_pass_fixture_entries(file).map(&:first)
      entries.each_slice([entries.size / PER_FILE, 1].max).map(&:first)
    end
    sampled.empty? ? REFS.fetch(flavor, []) : sampled
  end

  def self.pass_files(flavor)
    dir = File.join(ROOT, DIRS.fetch(flavor, flavor))
    Dir.glob(["#{dir}/pass/*.txt", "#{dir}/identifiers/pass/*.txt"])
  end
end

# Cross-flavor contract for `to_s(with_publisher:)` (relaton#49), run over a
# sample of every flavor's pass fixtures:
#
#   with_publisher: true / false -> never raises
#   with_publisher: false        -> no leading space, "-", "/" or ".", and
#                                   a suffix of the default (IETF adds a
#                                   label, so the default is a suffix of it)
#   option omitted               -> the default rendering, unchanged
#   to_mr_string                 -> not affected by the option
#
# Registry-driven, like spec/pubid/parse_error_spec.rb: a new flavor is
# covered by its fixtures, and a flavor with no fixtures must name a
# reference in WithPublisherContractSample::REFS, so none drops out silently.
RSpec.describe "to_s(with_publisher:) contract (cross-flavor)" do
  def mr_of(id)
    id.to_mr_string
  rescue StandardError, NotImplementedError => e
    e.class
  end

  def contract_failures(id, input)
    default = id.to_s
    mr = mr_of(id)
    id.to_s(with_publisher: true)
    internal = id.to_s(with_publisher: false)

    [
      ("false gave #{internal.inspect}" if internal.empty? ||
        internal.match?(%r{\A[\s\-/.]})),
      ("false is no suffix: #{internal.inspect}" unless
        default.end_with?(internal) || internal.end_with?(default)),
      ("default moved" unless id.to_s == default),
      ("MR moved" unless mr_of(id) == mr),
    ].compact.map { |problem| "#{input}: #{problem}" }
  rescue StandardError => e
    ["#{input}: raised #{e.class}: #{e.message}"]
  end

  # One example per flavor module; `cen` is an alias of `cen_cenelec`.
  Pubid::Registry.flavor_names.map(&:to_s).sort
    .uniq { |name| Pubid::Registry.get(name) }
    .each do |flavor|
      it "holds for #{flavor}" do
        mod = Pubid::Registry.get(flavor)
        inputs = WithPublisherContractSample.inputs(flavor)
        expect(inputs).not_to be_empty

        failures = inputs.flat_map do |input|
          id = begin
            mod.parse(input)
          rescue StandardError
            next [] # a pass fixture the classifier has not re-run on
          end
          contract_failures(id, input)
        end

        expect(failures).to be_empty
      end
    end
end
