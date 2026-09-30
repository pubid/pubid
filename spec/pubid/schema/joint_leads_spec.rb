# frozen_string_literal: true

require "spec_helper"

# The lead publisher of a joint prefix names the flavor that owns the joint
# document (pubid#465): prefix routing tries it first, and
# Identifier#canonical_hash takes its reading.
RSpec.describe Pubid::JOINT_LEADS do
  it "is sourced from schema/core/joint_prefixes.yaml" do
    expect(described_class).to eq(
      "ISO/IEC" => :iso,
      "IEC/ISO" => :iec,
      "ISO/IEC/IEEE" => :iso,
    )
  end

  it "is frozen" do
    expect(described_class).to be_frozen
  end

  it "names, for each prefix, a flavor that owns that joint prefix" do
    described_class.each do |prefix, flavor|
      expect(Pubid::JOINT_PREFIXES.fetch(flavor)).to include(prefix)
    end
  end

  # ANSI accredits ASHRAE and AMCA standards; it does not publish them, so
  # the first token is not the owner and these prefixes carry no lead.
  it "gives no lead to an accreditation prefix" do
    expect(described_class.keys).not_to include("ANSI/ASHRAE", "ANSI/AMCA")
  end
end
