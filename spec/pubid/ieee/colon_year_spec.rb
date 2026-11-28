# frozen_string_literal: true

require "spec_helper"

# The bare IEEE publisher takes an ISO-style colon year
# ("IEEE 8802-1AE:2013/Amd.1-2015", relaton-data-ieee#10). The grammar rule
# is ieee_colon_year_identifier. Parser.normalize_input must not insert
# "Std" before such a number, because "IEEE Std …:YYYY" stays a grammar
# negative. The identifier renders the canonical IEEE dash face.
RSpec.describe "IEEE bare colon year" do
  subject(:klass) { Pubid::Ieee::Identifier }

  {
    "IEEE 8802-1AE:2013/Amd.1-2015" => "IEEE Std 8802-1AE-2013/Amd 1-2015",
    "IEEE 8802-1AE:2013/Amd.2-2015" => "IEEE Std 8802-1AE-2013/Amd 2-2015",
    "IEEE 8802-3:2021/Amd 10-2021" => "IEEE Std 8802-3-2021/Amd 10-2021",
    "IEEE 8802-1X:2013/Amd. 1" => "IEEE Std 8802-1X-2013/Amd 1",
  }.each do |ref, rendered|
    context ref.inspect do
      let(:id) { klass.parse(ref) }

      it "parses to an Amendment of the dated base" do
        expect(id).to be_a(Pubid::Ieee::Identifiers::Amendment)
        expect(id.base.year).to eq(ref[/:(\d{4})/, 1])
      end

      it "renders the canonical dash face" do
        expect(id.to_s).to eq(rendered)
      end

      it "is the same identifier as its dash face" do
        expect(klass.parse(rendered).to_hash).to eq(id.to_hash)
      end
    end
  end

  it "parses a bare colon-year standard" do
    expect(klass.parse("IEEE 8802-1AE:2013").to_s)
      .to eq("IEEE Std 8802-1AE-2013")
  end

  # IEEE amendment letters are usually lowercase ("802.1ab").
  {
    "IEEE 802.1ab:2013" => "IEEE Std 802.1ab-2013",
    "IEEE 802.11ac:2013/Amd 1-2015" => "IEEE Std 802.11ac-2013/Amd 1-2015",
  }.each do |ref, rendered|
    it "parses the lowercase-letter colon year #{ref.inspect}" do
      expect(klass.parse(ref).to_s).to eq(rendered)
    end
  end

  it "still inserts Std before a plain bare number" do
    expect(Pubid::Ieee::Parser.normalize_input("IEEE 1070-1995"))
      .to eq("IEEE Std 1070-1995")
  end

  # The grammar rule does not cover a colon year with a corrigendum.
  it "still rejects a colon year with a corrigendum" do
    expect { klass.parse("IEEE 8802-1AE:2013/Cor 1-2014") }
      .to raise_error(Pubid::Errors::ParseError)
  end
end
