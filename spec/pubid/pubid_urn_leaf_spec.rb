# frozen_string_literal: true

require "spec_helper"

# The leaf waves of the pubid-scheme URN (issue #670): every flavor whose
# schema is a flat core-plus-atoms table, landed together. Each row pins
# the canonical URN and asserts the round trip; the corpus-wide contract
# (emit, round-trip, injective, path-safe) is
# spec/pubid/pubid_urn_contract_spec.rb. Adobe and SAE have no fixture
# corpus, so these literals are their only net besides the contract's
# LITERALS.
RSpec.describe "the pubid-scheme URN leaf waves" do
  [
    ["xsf", "XEP 0001", "urn:pubid:xsf:xep:0001"],
    ["iana", "IANA _6lowpan-parameters",
     "urn:pubid:iana:registry:_6lowpan-parameters"],
    ["isbn", "ISBN 0-306-40615-2",
     "urn:pubid:isbn:book:hyphenated-0-306-40615-2:raw-0306406152"],
    ["doi", "doi:10.1000/182",
     "urn:pubid:doi:resource:prefix-10.1000:suffix-182"],
    ["omg", "OMG AMI4CCM 1.0", "urn:pubid:omg:spec:v-1.0:acronym-AMI4CCM"],
    ["un", "A/RES/78/1", "urn:pubid:un:document:1:path-A,RES,78"],
    ["w3c", "W3C REC-CSS1-19990111", "urn:pubid:w3c:rec:CSS1:date-19990111"],
    # "becss" reads as a type token by shape, so its first byte escapes
    ["w3c", "W3C becss", "urn:pubid:w3c:std:~62ecss"],
    ["oasis", "OASIS EDXL", "urn:pubid:oasis:std:EDXL:original-EDXL"],
    ["ogc", "OGC 06-121r9", "urn:pubid:ogc:document:121:year-06:rev-r9"],
    ["iala", "IALA G1195 Ed 1.0", "urn:pubid:iala:g:1195:ed-1.0"],
    ["iala", "IALA G1045 Annex Ed 1",
     "urn:pubid:iala:g:1045:annex:ed-1:annexform-Annex"],
    ["calconnect", "CC 11001:2024", "urn:pubid:calconnect:std:11001:year-2024"],
    ["easc", "ПМГ В 31-2001",
     "urn:pubid:easc:pmg:31:series-PMG:year-2001:variant-V"],
    ["ecma", "ECMA-434 ed1", "urn:pubid:ecma:std:434:ed-1"],
    ["ecma", "ECMA MEM/2026", "urn:pubid:ecma:memento:2026"],
    ["gb", "JB/T 13368-2018",
     "urn:pubid:gb:std:13368:pub-JB:year-2018:mandate-T"],
    ["gb", "GB/T 5606 (all parts)",
     "urn:pubid:gb:all:ids-(gb:std:5606:pub-GB:mandate-T)"],
    ["3gpp", "TR 01.00:REL-96/5.0.0",
     "urn:pubid:3gpp:tr:01.00:v-5.0.0:release-REL-96"],
    ["amca", "ANSI/AMCA 210-16 /ASHRAE 51-16",
     "urn:pubid:amca:std:210:co-ANSI~2FAMCA:year-16"],
    ["amca", "AMCA 99 JW Interp",
     "urn:pubid:amca:interp:99:co-AMCA:interpcode-JW"],
    ["ccsds", "CCSDS 100.0-G-1-S",
     "urn:pubid:ccsds:base:100:type-G:part-0:ed-1:suffix-S"],
    ["ccsds", "CCSDS 121.0-B-1-S Cor. 1",
     "urn:pubid:ccsds:base:121:type-B:part-0:ed-1:suffix-S:cor:1"],
    ["jis", "JIS A 0001:1999", "urn:pubid:jis:jis:0001:series-A:year-1999"],
    ["jis", "WES 7700-1:2019", "urn:pubid:jis:wes:7700:part-1:year-2019"],
    # a draft name ("draft-…") reads as a type token by shape
    ["ietf", "draft-3gpp-collaboration-01",
     "urn:pubid:ietf:id2:~64raft-3gpp-collaboration:v-01"],
    ["ietf", "BCP 3", "urn:pubid:ietf:bcp:3"],
    ["evs", "EVS-EN 18216:2026",
     "urn:pubid:evs:cencenelec.en:18216:year-2026:na"],
    ["evs", "EVS 921:2019", "urn:pubid:evs:es:921:year-2019:f:0.separator-~20"],
    ["cie", "CIE S 004/E-2001",
     "urn:pubid:cie:std:004:year-2001:lang-E:langformat-slash:style-legacy:" \
     "f:0.sp-true"],
    ["cie", "CIE x043-OP01", "urn:pubid:cie:p:OP01:conference-043"],
    ["cie", "CIE ISO 10916:2024", "urn:pubid:cie:jp:10916:co-ISO:year-2024"],
    ["cie", "CIE 198-SP1.4:2011/Cor1:2013",
     "urn:pubid:cie:std:198:year-2011:sup:1:part-4:cor:1:year-2013"],
    ["adobe", "Adobe TN 5014", "urn:pubid:adobe:technote:5014"],
    ["adobe", "adobe-japan1-7", "urn:pubid:adobe:pub:slug-adobe-japan1:v-7"],
    ["sae", "SAE J3016_202104",
     "urn:pubid:sae:id:3016:typeabbr-J:year-2021:month-4"],
    ["sae", "SAE ARP4754A:2010",
     "urn:pubid:sae:id:4754:typeabbr-ARP:rev-A:yearflat-2010"],
    ["sae", "SAE AMS-QQ-A-250/4B",
     "urn:pubid:sae:id:250:typeabbr-AMS-QQ-A:rev-B:part-4"],
  ].each do |flavor, input, urn|
    # The registry maps are populated at flavor-module load (autoload is
    # lazy), so load the flavor before looking it up.
    require "pubid/#{flavor == "3gpp" ? "tgpp" : flavor}"

    describe "#{flavor}: #{input}" do
      it "renders as #{urn}" do
        expect(Pubid::Registry.get(flavor).parse(input).to_pubid_urn).to eq(urn)
      end

      it "round-trips by to_hash" do
        id = Pubid::Registry.get(flavor).parse(input)
        back = Pubid.parse_urn(id.to_pubid_urn)
        expect(back.to_hash).to eq(id.to_hash)
        expect(back.to_s).to eq(id.to_s)
      end
    end
  end
end
