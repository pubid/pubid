# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/pubid/bsi"

RSpec.describe "BSI Integration Tests" do
  # Test format: [input, expected_output (if different from input)]
  test_cases = [
    # Basic identifiers
    ["BS 0"],
    ["BS 7121-3:2017"],
    ["PAS 1192-2:2014"],
    ["PD 19650-0:2019"],

    # Flex documents
    ["Flex 8670:2021-04", "BSI Flex 8670:2021-04"],
    ["Flex 8670 v3.0:2021-04", "BSI Flex 8670 v3.0:2021-04"],
    ["BSI Flex 1889 v1.0:2022-07"],

    # Simple adopted documents
    ["ISO 37101:2016"],
    ["ISO/IEC 29151"],
    ["IEC 62366-1"],
    ["IEC 60384-23:2023 ED3"],
    ["IEC 61834-1:1998+AMD1:2001 CSV"],

    # Draft documents
    ["DD 240-1:1997"],

    # Consolidated identifiers (amendments and corrigenda)
    ["BS 4592-0:2006+A1:2012"],
    ["PD 5500:2021+A2:2022"],
    ["PAS 3002:2018+C1:2018"],

    # Adopted documents with technical reports
    ["PD IEC/TR 80002-3:2014", "PD IEC TR 80002-3:2014"],

    # Adopted BS-wrapped documents
    ["BS ISO/IEC 30134-1:2016"],
    ["BS ISO/PRF PAS 5643", "BS ISO/PRF PAS 5643"], # v2 preserves PRF correctly
    ["BS ISO/DIS 22000:2017"],
    ["BS ISO/DIS 9004.1:2017"],
    ["BS ISO/FDIS 22301:2012"],

    # CEN/TS adopted documents
    ["DD CEN/TS 1992-4-2:2009"],
    ["PD CEN/TS 16415:2013"],

    # EN adopted documents
    ["BS EN 15154-5:2019"],

    # 2-level adoptions (BS EN ISO, BS EN IEC)
    ["BS EN ISO 13485:2012"],
    ["BS EN ISO 13485:2016+A11:2021"],
    ["BS EN IEC 62368-1:2020+A11:2020"],
    ["BS EN ISO/IEC 80079-34:2020 ED2"],
    ["PD CISPR TR 16-4-5:2006+A2:2021"],

    # Expert commentary identifiers
    ["BS 5250:2021 ExComm"],
    ["BS 7273-4:2015+A1:2021 ExComm"],
    ["BS EN ISO 13485:2016+A11:2021 ExComm"],
    ["BS EN 61000-3-3:2013+A2:2021 ExComm"],
    ["BS EN IEC 62115:2020+A11:2020 ExComm"],
    ["BS EN ISO/IEC 80079-34:2020 ExComm"],

    # TC documents
    ["PAS 96:2017 - TC"],

    # National Annexes
    ["NA to BS EN 1999-1-2:2007"],
    ["NA+A1:2012 to BS EN 1993-5:2007"],
    ["NA+A1:15 to BS EN 1993-1-4:2006+A1:2015",
     "NA+A1:2015 to BS EN 1993-1-4:2006+A1:2015"],
    ["NA+A2:18 to BS EN 1991-1-3:2003+A1:2015",
     "NA+A2:2018 to BS EN 1991-1-3:2003+A1:2015"],

    # Translations
    ["BS 25999-1:2006 (German)"],
    ["PAS 99:2006 (Italian Translation)", "PAS 99:2006 (Italian)"],
    ["PAS 9017:2020+C1 SPANISH TRANSLATION", "PAS 9017:2020+C1 (Spanish)"],
    ["BS ISO/IEC 17799:2005 (French version)",
     "BS ISO/IEC 17799:2005 (French)"],

    # PDF
    ["PD 5500:2018+A3:2020 PDF"],

    # Collections
    ["PAS 2035/2030:2019+A1:2022"],
  ]

  test_cases.each do |test_input, expected_output|
    expected_output ||= test_input

    context "when parsing '#{test_input}'" do
      it "round-trips correctly to '#{expected_output}'" do
        parsed = Pubid::Bsi.parse(test_input)
        expect(parsed.to_s).to eq(expected_output)
      end
    end
  end
end
