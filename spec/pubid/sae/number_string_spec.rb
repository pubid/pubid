# frozen_string_literal: true

require "spec_helper"

# SAE holds `number` as a plain :string, like every converted flavor. Its
# `Sae::Components::Code` was a bare alias of the shared component
# (`Code = Pubid::Components::Code`), so the component never carried anything
# but `value` and the retype is a representation change only.
#
# SAE has no fixture corpus, so the references below come from the SAE specs.
# There is no `relaton-data-sae`, so the wire-format flattening
# (`{"value" => "1936"}` -> `"1936"`) reaches no published index.
module SaeNumberStringSpec
  # Namespaced: a bare constant inside an RSpec block leaks into Object and
  # collides with another spec file (annotated_rendering_spec also has REFS).
  REFS = {
    "SAE AIR1936" => ["SAE AIR 1936", "urn:sae:air:1936", "1936"],
    "SAE AMS5000:2020" => ["SAE AMS 5000:2020", "urn:sae:ams:5000:2020", "5000"],
    "SAE J1939" => ["SAE J 1939", "urn:sae:j:1939", "1939"],
    "SAE J300:2019" => ["SAE J 300:2019", "urn:sae:j:300:2019", "300"],
    # The URN keeps the letter suffix's case; only the type segment is
    # lowercased. Pinned as measured, not as preferred.
    "SAE ARP4754A" => ["SAE ARP 4754A", "urn:sae:arp:4754A", "4754A"],
  }.freeze
end

RSpec.describe "SAE number as a string" do
  describe "the attribute type" do
    it "declares number as a plain string" do
      expect(Pubid::Sae::Identifier.attributes[:number].type)
        .to eq(Lutaml::Model::Type::String)
    end
  end

  SaeNumberStringSpec::REFS.each do |ref, (printed, urn, number)|
    context "with #{ref}" do
      let(:id) { Pubid::Sae.parse(ref) }

      it "keeps number a String" do
        expect(id.number).to be_a(String)
        expect(id.number).to eq(number)
        expect(id.root.number).to eq(number)
      end

      it "renders and serializes as before" do
        expect(id.to_s).to eq(printed)
        expect(id.to_urn).to eq(urn)
        expect(id.to_hash["number"]).to eq(number)
      end

      it "round-trips through from_hash" do
        hash = id.to_hash

        expect(Pubid::Sae::Identifier.from_hash(hash).to_hash).to eq(hash)
      end
    end
  end
end
