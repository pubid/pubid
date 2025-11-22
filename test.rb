identifier = PubidNew::Iso::Identifier.parse("ISO 4214:2022 | IDF/RM 254:2022")
identifier.to_s


identifier = PubidNew::Iso::Identifier.parse("Guide ISO/CEI 51:1999(F/E/R)")
identifier.to_s


identifier = PubidNew::Iso::Identifier.parse("ISO 17301-1:2016/FDCOR 1.3:2022")
identifier.to_s


identifier = PubidNew::Iso::Identifier.parse("ISO/IEC Directives IEC SUP:2022")
identifier.to_s

identifier = PubidNew::Iso::Identifier.parse("ISO/IEC Directives, IEC Supplement:2022")

identifier = PubidNew::Iso::Identifier.parse("ISO/IEC 10646-1:1993/pDCOR. 2")


identifier = PubidNew::Iso::Identifier.parse("ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017")
identifier.to_s

identifier = PubidNew::Iso::Identifier.parse("ISO/IEC 13818-1:2015")
identifier.to_s

identifier = PubidNew::Iso::Identifier.parse("ISO/IEC AWI TR 24030")
identifier.to_s


identifier = PubidNew::Iso::Identifier.parse("ISO 15002:2008/DAM 2:2020(F)")
identifier.to_s(lang_single: true)

# TODO: implement language-aware French / Russian pubids

# TODO: ISO/IEC DIR 1:2022 + IEC SUP:2022
# Need to parse and build it as a collection of two identifiers

# TODO:
# ISO 9232 | IDF 146:2003 / AMD 1:2023
# ISO 9233-1 | IDF 140-1: 2007 / AMD1: 2012
# ISO 13366-1 | IDF 148-1:2008 / COR 1:2009
# Need to parse and build it as a joint identifier (an identifier that has 2 identifiers)
identifier = PubidNew::Idf::Identifier.parse("IDF 263")

identifier = PubidNew::Idf::Identifier.parse("IDF 125A:1988")

identifier = PubidNew::Idf::Identifier.parse("IDF 124-2:2005")
identifier = PubidNew::Idf::Identifier.parse("IDF/RM 82:2004")
