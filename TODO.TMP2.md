Corrigendum
# TODO identifiers to test

# Basic:
# - ISO 10360-1:2000/Cor 1:2002
# - ISO/IEEE 11073-10418:2014/Cor 1:2016

# Legacy:
# - ISO 105-G01:1993/COR 1:1995
# - ISO 6709:2008/Cor. 1:2009
# - ISO 9606-1:2012/Cor.2:2013(F)
# - ISO/IEC 17025:2005/Cor.1:2006(fr)

# Stages:
# preliminary:
# - ISO 3822-3:1997/PWI Cor 1
# proposal:
# - ISO 10303-111:2007/NP Cor 2
# preparatory:
# - ISO 13431:1999/AWI Cor 1
# - ISO 13431:1999/WD Cor 1
# committee:
# - ISO 3864-2:2004/CD Cor 1
# - ISO/IEC ISP 10611-4:1997/CD Cor 2
# - ISO/IEC 15408-2:1999/CD Cor 1
# enquiry:
# - ISO/IEC 14496-12/DCOR 1
# approval:
# - ISO/TR 23455:2019/FDCor 1

# pDCOR
# - ISO/IEC 10646-1:1993/pDCOR.2

# Stage with iteration
# - ISO 17301-1:2016/DCor 1.3:2002
# ISO 17301-1:2016/DCor 2.3
# ISO 17301-1:2016/DCOR 1.3:2002
# ISO 17301-1:2016/FDCor 1.3:2022
# ISO 17301-1:2016/FDCOR 1.3:2022
# ISO 17301-1:2016/FDCor 2.3
# ISO 17301-1:2016/FCOR 2.3

# Corrigendum of Amendment
# ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017
# ISO/IEC 15938-7:2003/Amd 5:2010/CD Cor 1

#     context "ISO 10360-1/Cor 1:2002" do
#       let(:pubid) { "ISO 10360-1/Cor 1:2002" }
#       let(:urn) { "urn:iso:std:iso:10360:-1:cor:2002:v1" }

#       it_behaves_like "converts urn to pubid"
#     end

#     context "ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017" do
#       let(:original) { "ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017 ED5" }
#       let(:pubid) { "ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017" }
#       let(:urn) { "urn:iso:std:iso-iec:13818:-1:ed-5:amd:2016:v3:cor:2017:v1" }

#       it_behaves_like "converts pubid to urn"
#       it_behaves_like "converts pubid to pubid"
#       it_behaves_like "converts urn to pubid", "ISO/IEC 13818-1 ED5/Amd 3:2016/Cor 1:2017"

#       it "should have type :cor" do
#         expect(subject.type[:key]).to eq(:cor)
#       end

#       it "should have amendment as base identifier" do
#         expect(subject.base.type[:key]).to eq(:amd)
#       end

#       it "should have base document for amendment" do
#         expect(subject.base.base).to be_a(Identifier::InternationalStandard)
#       end

#       it "returns root identifer" do
#         expect(subject.root).to eq(subject.base.base)
#       end
#     end

#     context "ISO 11783-2:2012/Cor.1:2012(fr)" do
#       let(:original) { "ISO 11783-2:2012/Cor.1:2012 ED2(fr)" }
#       let(:pubid) { "ISO 11783-2:2012/Cor 1:2012(fr)" }
#       let(:urn) { "urn:iso:std:iso:11783:-2:ed-2:cor:2012:v1:fr" }

#       it_behaves_like "converts pubid to urn"
#       it_behaves_like "converts pubid to pubid"
#       it_behaves_like "converts urn to pubid", "ISO 11783-2 ED2/Cor 1:2012(fr)"
#     end


#     context "ISO/IEC 17025:2005/Cor.1:2006(fr)" do
#       let(:original) { "ISO/IEC 17025:2005/Cor.1:2006 ED1(fr)" }
#       let(:pubid) { "ISO/IEC 17025:2005/Cor 1:2006(fr)" }
#       let(:pubid_without_date) { "ISO/IEC 17025:2005/Cor 1" }
#       let(:pubid_single_letter_language) { "ISO/IEC 17025:2005/Cor 1:2006(F)" }
#       let(:pubid_with_edition) { "ISO/IEC 17025:2005 ED1/Cor 1:2006(fr)" }
#       let(:french_pubid) { "ISO/CEI 17025:2005/Cor.1:2006(fr)" }
#       let(:urn) { "urn:iso:std:iso-iec:17025:ed-1:cor:2006:v1:fr" }

#       it_behaves_like "converts pubid to urn"
#       it_behaves_like "converts pubid to pubid"
#       it_behaves_like "converts pubid to french pubid"
#       it_behaves_like "converts urn to pubid", "ISO/IEC 17025 ED1/Cor 1:2006(fr)"

#       it "converts to pubid without date" do
#         expect(subject.to_s(format: :ref_undated_long)).to eq(pubid_without_date)
#       end

#       it "converts to pubid with single letter language code" do
#         expect(subject.to_s(format: :ref_num_short)).to eq(pubid_single_letter_language)
#       end

#       it_behaves_like "converts to pubid with edition"
#     end


#     context "ISO 17301-1:2016/FCOR 2.3" do
#       let(:original) { "ISO 17301-1:2016/FCOR 2.3" }
#       let(:pubid) { "ISO 17301-1:2016/FDCOR 2.3" }

#       it_behaves_like "converts pubid to pubid"
#     end


#     context "ISO/IEC Guide 98-3:2008/Suppl 1:2008/Cor 1:2009" do
#       let(:pubid) { "ISO/IEC Guide 98-3:2008/Suppl 1:2008/Cor 1:2009" }

#       it_behaves_like "converts pubid to pubid"
#     end

#     context "ISO/IEC Guide 98-3 ED1/Suppl 1:2008/Cor 1:2009" do
#       let(:pubid) { "ISO/IEC Guide 98-3 ED1/Suppl 1:2008/Cor 1:2009" }
#       let(:urn) { "urn:iso:std:iso-iec:guide:98:-3:ed-1:sup:2008:v1:cor:2009:v1" }

#       it_behaves_like "converts pubid to urn"
#       it_behaves_like "converts urn to pubid"
#     end

#     context "ISO 6709:2008/Cor. 1:2009" do
#       let(:original) { "ISO 6709:2008/Cor. 1:2009 ED2" }
#       let(:pubid) { "ISO 6709:2008/Cor 1:2009" }
#       let(:urn) { "urn:iso:std:iso:6709:ed-2:cor:2009:v1" }

#       it_behaves_like "converts pubid to urn"
#       it_behaves_like "converts pubid to pubid"
#       it_behaves_like "converts urn to pubid", "ISO 6709 ED2/Cor 1:2009"
#     end
