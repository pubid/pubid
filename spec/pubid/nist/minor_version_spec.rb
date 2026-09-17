# frozen_string: true

require "spec_helper"

# pubid#170: NIST publications with MINOR version numbers ("2.0", "1.1",
# "1.0.1") do not fit the 2022 scheme's <edition-id> ({1-9}|yyyy). The
# publications are real, so pubid parses them, keeps the dotted version in
# the canonical hash (version_component) and round-trips idempotently.
# Whether the scheme itself will admit dotted edition-ids is a question
# NIST was asked in 2022 (see the issue); this spec locks the behaviour
# that exists meanwhile.
RSpec.describe "NIST minor version numbers — issue #170" do
  subject(:klass) { Pubid::Nist::Identifier }

  {
    "NIST SP 1011-I-2.0" => "2.0",
    "NIST SP 500-268v1.1" => "1.1",
    "NIST SP 500-281-v1.0" => "1.0",
    "NIST SP 800-63v1.0.1" => "1.0.1",
    "NIST SP 500-281.ver1.0" => "1.0",
  }.each do |input, version|
    context input.inspect do
      it "keeps the dotted version in the canonical hash" do
        expect(klass.parse(input).to_hash["version_component"])
          .to eq("value" => version)
      end

      it "round-trips through to_hash/from_hash as an equal identifier" do
        id = klass.parse(input)
        expect(klass.from_hash(id.to_hash)).to eq(id)
      end

      it "reaches its to_s fixed point" do
        out = klass.parse(input).to_s
        expect(klass.parse(out).to_s).to eq(out)
      end
    end
  end
end
