# frozen_string_literal: true

require "spec_helper"

RSpec.describe "IEEE /Amd parser parity with /Cor — issue #210" do
  # The parser historically accepted /Cor N-YYYY in IEEE format but rejected
  # the parallel /Amd N-YYYY form. The fix mirrors the Corrigendum rule's
  # separator flexibility for amendments.

  {
    "IEEE Std 1003.1-2001/Amd 2-2004" => "slash + space + dash",
    "IEEE Std 802.3-2018/Amd 1-2019" => "slash + space + dash",
    "IEEE Std 802.3-2018/Amd1-2019" => "slash + attached number",
    "IEEE Std 802.3-2018/Amd8-2019" => "slash + attached multi-digit",
  }.each do |identifier, desc|
    describe "#{identifier} (#{desc})" do
      it "parses without raising" do
        expect { Pubid::Ieee.parse(identifier) }.not_to raise_error
      end

      it "parses the base IEEE Standard" do
        parsed = Pubid::Ieee.parse(identifier)
        expect(parsed.to_s).to start_with("IEEE Std 802.3-2018")
          .or start_with("IEEE Std 1003.1-2001")
      end
    end
  end

  describe "regression: /Cor still works" do
    it "parses IEEE Std 1003.1-2001/Cor 2-2004" do
      parsed = Pubid::Ieee.parse("IEEE Std 1003.1-2001/Cor 2-2004")
      expect(parsed).to be_a(Pubid::Ieee::Identifiers::Corrigendum)
    end
  end
end
