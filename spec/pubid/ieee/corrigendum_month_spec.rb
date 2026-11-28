# frozen_string_literal: true

require "spec_helper"

# A corrigendum can carry a numeric month after its year
# ("…/Cor 1-2019-05"). The grammar captures it as `cor_month`
# (pubid-grammar, relaton-data-ieee#10); before that the month was dropped.
# It rides the `month` attribute the Corrigendum inherits.
RSpec.describe "IEEE corrigendum month" do
  subject(:klass) { Pubid::Ieee::Identifier }

  {
    "IEEE P1591.1/D-1/Cor1-2025-05" =>
      ["IEEE P1591.1/D1/Cor. 1-2025-05", "1", "2025"],
    "IEEE P1591.1/D1/Cor. 1-2025-05" =>
      ["IEEE P1591.1/D1/Cor. 1-2025-05", "1", "2025"],
    "IEEE Std 802.3-2018/Cor 1-2019-05" =>
      ["IEEE Std 802.3-2018/Cor. 1-2019-05", "1", "2019"],
  }.each do |ref, (rendered, number, year)|
    context ref.inspect do
      let(:id) { klass.parse(ref) }

      it "builds a Corrigendum with its month" do
        expect(id).to be_a(Pubid::Ieee::Identifiers::Corrigendum)
        expect([id.number, id.year, id.month]).to eq([number, year, "05"])
      end

      it "renders the month after the corrigendum year" do
        expect(id.to_s).to eq(rendered)
      end

      it "keeps the month off the base document" do
        expect(id.base.month).to be_nil
      end

      it "parses its rendering back to the same identifier" do
        expect(klass.parse(id.to_s).to_hash).to eq(id.to_hash)
      end

      it "is equal after from_hash(to_hash)" do
        expect(klass.from_hash(id.to_hash)).to eq(id)
      end

      it "round-trips the pubid URN" do
        expect(Pubid.parse_urn(id.to_pubid_urn).to_hash).to eq(id.to_hash)
      end

      it "drops the month with the year on exclude(:year)" do
        expect(id.exclude(:year).month).to be_nil
      end
    end
  end

  it "gives monthly corrigenda distinct identities" do
    a = klass.parse("IEEE Std 802.3-2018/Cor 1-2019-05")
    b = klass.parse("IEEE Std 802.3-2018/Cor 1-2019-06")
    expect(a).not_to eq(b)
    expect(a.to_pubid_urn).not_to eq(b.to_pubid_urn)
    expect(a.to_mr_string).not_to eq(b.to_mr_string)
  end

  it "puts the month once into the official URN" do
    id = klass.parse("IEEE Std 802.3-2018/Cor 1-2019-05")
    expect(id.to_urn.scan(":05").size).to eq(1)
    expect(id.to_urn)
      .not_to eq(klass.parse("IEEE Std 802.3-2018/Cor 1-2019").to_urn)
  end

  it "leaves a month-less corrigendum unchanged" do
    id = klass.parse("IEEE Std 802.3-2018/Cor 1-2019")
    expect(id.month).to be_nil
    expect(id.to_s).to eq("IEEE Std 802.3-2018/Cor. 1-2019")
  end
end
