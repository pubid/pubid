# module PubidNew
#   RSpec.describe Identifier do
#     shared_examples "converts pubid to pubid" do
#       it "converts pubid to pubid" do
#         # expect(subject.to_s(format: :ref_num_long)).to eq(pubid)
#         expect(subject.to_s).to eq(pubid)
#       end

#       it "creates same identifier from #to_h output" do
#         expect(subject.to_s).to eq(PubidNew::Identifier.create(**subject.to_h).to_s)
#       end
#     end

#     subject { described_class.parse(original || pubid) }
#     let(:original) { nil }
#     let(:french_pubid) { original }
#     let(:russian_pubid) { original }
#     let(:pubid_with_edition) { original }

#     context "FprISO 105-A03" do
#       let(:original) { "FprISO 105-A03" }
#       let(:pubid) { "ISO/PRF 105-A03" }
#       let(:urn) { "urn:iso:std:iso:105:-A03:stage-draft" }

#       it_behaves_like "converts pubid to urn"
#       it_behaves_like "converts pubid to pubid with prf"
#       it_behaves_like "converts urn to pubid", "ISO/DIS 105-A03"
#     end

#     context "IEC 80601-2-60" do
#       let(:pubid) { "IEC 80601-2-60" }
#       let(:urn) { "urn:iso:std:iec:80601:-2-60" }

#       it_behaves_like "converts pubid to urn"
#       it_behaves_like "converts pubid to pubid"
#       it_behaves_like "converts urn to pubid"
#     end

#     context "GUIDE ISO/CEI 71:2001(F)" do
#       let(:original) { "GUIDE ISO/CEI 71:2001(F)" }
#       let(:pubid) { "ISO/IEC Guide 71:2001(fr)" }
#       let(:french_pubid) { "Guide ISO/CEI 71:2001(fr)" }
#       let(:urn) { "urn:iso:std:iso-iec:guide:71:fr" }

#       it_behaves_like "converts pubid to urn"
#       it_behaves_like "converts pubid to pubid"
#       it_behaves_like "converts pubid to french pubid"
#       it_behaves_like "converts urn to pubid", "ISO/IEC Guide 71(fr)"
#     end

#     context "Руководство ИСО/МЭК 76" do
#       let(:original) { "Руководство ИСО/МЭК 76" }
#       let(:pubid) { "ISO/IEC Guide 76" }
#       let(:urn) { "urn:iso:std:iso-iec:guide:76" }

#       it_behaves_like "converts pubid to urn"
#       it_behaves_like "converts pubid to pubid"
#       it_behaves_like "converts pubid to russian pubid"
#       it_behaves_like "converts urn to pubid", "ISO/IEC Guide 76"
#     end

#     context "ИСО/ОПМС 26000:2010(R)" do
#       let(:original) { "ИСО/ОПМС 26000:2010(R)" }
#       let(:pubid) { "ISO/FDIS 26000:2010(ru)" }
#       let(:russian_pubid) { "ИСО/ОПМС 26000:2010(ru)" }
#       let(:urn) { "urn:iso:std:iso:26000:stage-draft:ru" }

#       it_behaves_like "converts pubid to urn"
#       it_behaves_like "converts pubid to pubid"
#       it_behaves_like "converts pubid to russian pubid"
#       it_behaves_like "converts urn to pubid", "ISO/DIS 26000(ru)"
#     end

#     context "ИСО/ПМС 1956/2" do
#       let(:original) { "ИСО/ПМС 1956/2" }
#       let(:pubid) { "ISO/DIS 1956-2" }
#       let(:urn) { "urn:iso:std:iso:1956:-2:stage-draft" }

#       it_behaves_like "converts pubid to urn"
#       it_behaves_like "converts pubid to pubid"
#       it_behaves_like "converts urn to pubid", "ISO/DIS 1956-2"
#     end

#     context "ИСО/ТС 18625" do
#       let(:original) { "ИСО/ТС 18625" }
#       let(:pubid) { "ISO/TS 18625" }
#       let(:urn) { "urn:iso:std:iso:ts:18625" }

#       it_behaves_like "converts pubid to urn"
#       it_behaves_like "converts pubid to pubid"
#       it_behaves_like "converts urn to pubid", "ISO/TS 18625"
#     end

#     context "ИСО/ТО 8517" do
#       let(:original) { "ИСО/ТО 8517" }
#       let(:pubid) { "ISO/TR 8517" }
#       let(:urn) { "urn:iso:std:iso:tr:8517" }

#       it_behaves_like "converts pubid to urn"
#       it_behaves_like "converts pubid to pubid"
#       it_behaves_like "converts urn to pubid", "ISO/TR 8517"
#     end

#     context "ИСО/ТС 18625" do
#       let(:original) { "ИСО/ТС 18625" }
#       let(:pubid) { "ISO/TS 18625" }
#       let(:urn) { "urn:iso:std:iso:ts:18625" }

#       it_behaves_like "converts pubid to urn"
#       it_behaves_like "converts pubid to pubid"
#       it_behaves_like "converts urn to pubid", "ISO/TS 18625"
#     end

#     context "IEC/DPAS 63086-3-1" do
#       let(:pubid) { "IEC/DPAS 63086-3-1" }
#       let(:urn) { "urn:iso:std:iec:pas:63086:-3-1:stage-draft" }

#       it_behaves_like "converts pubid to pubid"
#       it_behaves_like "converts pubid to urn"
#       it_behaves_like "converts urn to pubid", "IEC/DPAS 63086-3-1"
#     end

#     context "URN with numered stage" do
#       context "Base" do
#         context "60.60" do
#           let(:urn) { "urn:iso:std:iec:60086:-3:stage-60.60" }
#           it_behaves_like "converts urn to pubid", "IEC/IS 60086-3"
#           it_behaves_like "converts urn to urn", "urn:iso:std:iec:60086:-3:stage-published"
#         end

#         context "95.99" do
#           let(:urn) { "urn:iso:std:iec:31010:stage-95.99" }
#           it_behaves_like "converts urn to pubid", "IEC/WDAR 31010"
#           it_behaves_like "converts urn to urn"
#         end
#       end

#       context "Suppliment" do
#         context "60.00" do
#           let(:urn) { "urn:iso:std:iso:10033:-1:ed-1:stage-60.00:amd:1:v1"}
#           it_behaves_like "converts urn to pubid", "ISO 10033-1 ED1/IS Amd 1"
#           it_behaves_like "converts urn to urn", "urn:iso:std:iso:10033:-1:ed-1:stage-published:amd:1:v1"
#         end

#         context "60.60" do
#           let(:urn) { "urn:iso:std:iec:60086:-3:ed-4:stage-60.60:cor:2023:v1" }
#           it_behaves_like "converts urn to pubid", "IEC 60086-3 ED4/IS Cor 1:2023"
#           it_behaves_like "converts urn to urn", "urn:iso:std:iec:60086:-3:ed-4:stage-published:cor:2023:v1"
#         end

#         context "90.92" do
#           let(:urn) { "urn:iso:std:iso:11930:ed-2:stage-90.92:amd:2022:v1" }
#           it_behaves_like "converts urn to pubid", "ISO 11930 ED2/WDR Amd 1:2022"
#           it_behaves_like "converts urn to urn"
#         end

#         context "90.93" do
#           let(:urn) { "urn:iso:std:iso:12085:ed-1:stage-90.93:cor:1998:v1" }
#           it_behaves_like "converts urn to pubid", "ISO 12085 ED1/WDA Cor 1:1998"
#           it_behaves_like "converts urn to urn"
#         end

#         context "95.99 Cor" do
#           let(:urn) { "urn:iso:std:iec:60601:-1-11:ed-1:stage-95.99:cor:2011:v1" }
#           it_behaves_like "converts urn to pubid", "IEC 60601-1-11 ED1/WDAR Cor 1:2011"
#           it_behaves_like "converts urn to urn"
#         end

#         context "95.99" do
#           let(:urn) { "urn:iso:std:iso:1151:-2:ed-2:stage-95.99:sup:1987:v1" }
#           it_behaves_like "converts urn to pubid", "ISO 1151-2 ED2/WDAR Suppl 1:1987"
#           it_behaves_like "converts urn to urn"
#         end
#       end

#       context "Extension" do
#         context "95.99" do
#           let(:urn) { "urn:iso:std:iso:1101:ed-1:stage-95.99:ext:1983:v1" }
#           it_behaves_like "converts urn to pubid", "ISO 1101 ED1/Ext 1:1983"
#           it_behaves_like "converts urn to urn", "urn:iso:std:iso:1101:ed-1:ext:1983:v1"
#         end
#       end
#     end

#     context "all parts" do
#       context "Base" do
#         let(:pubid) { "ISO/IEC FDIS 7816 (all parts)" }
#         let(:urn) { "urn:iso:std:iso-iec:7816:stage-draft:ser" }

#         it_behaves_like "converts pubid to pubid"
#         it_behaves_like "converts pubid to urn"
#         it_behaves_like "converts urn to pubid", "ISO/IEC DIS 7816 (all parts)"
#       end

#       context "Corrigendum" do
#         let(:original) { "ISO/IEC Guide 98 ED1/Suppl 1:2008/Cor 1:2009 (all parts)" }
#         let(:pubid) { "ISO/IEC Guide 98/Suppl 1:2008/Cor 1:2009 (all parts)" }
#         let(:urn) { "urn:iso:std:iso-iec:guide:98:ed-1:sup:2008:v1:cor:2009:v1:ser" }

#         it_behaves_like "converts pubid to pubid"
#         it_behaves_like "converts pubid to urn"
#         it_behaves_like "converts urn to pubid"
#       end

#       context "Addendment" do
#         let(:original) { "ISO/IEC 14496:2018/FDAmd 1 ED2 (all parts)" }
#         let(:pubid) { "ISO/IEC 14496:2018/FDAM 1 (all parts)" }
#         let(:urn) { "urn:iso:std:iso-iec:14496:ed-2:stage-draft:amd:1:v1:ser" }

#         it_behaves_like "converts pubid to pubid"
#         it_behaves_like "converts pubid to urn"
#         it_behaves_like "converts urn to pubid", "ISO/IEC 14496 ED2/WD Amd 1 (all parts)"
#       end

#       context "Supplement" do
#         let(:pubid) { "ISO 8501:1988/Suppl:1994 (all parts)" }
#         let(:urn) { "urn:iso:std:iso:8501:sup:1994:ser" }

#         it_behaves_like "converts pubid to pubid"
#         it_behaves_like "converts pubid to urn"
#       end
#     end

#     context "URN stage-published" do
#       let(:urn) { "urn:iso:std:iso:19115:-3:stage-published" }
#       it_behaves_like "converts urn to pubid", "ISO/IS 19115-3"
#     end

#     context "iso-reference" do
#       # let(:pubid) { "ISO 21622-3.2(E)" }
#       # it_behaves_like "converts pubid to pubid"
#     end
#   end
# end
