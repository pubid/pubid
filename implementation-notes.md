## Task

The task is to fix `bundle rake test:all` per flavor.

## Implementation Notes

We need a pubid algebra:

* combined document: pubid '+' pubid means that a two documents are combined into a new document. e.g. In CEN: "EN 10077-1:2006+AC:2009+AC2:2009" means that the document EN 10077-1:2006 has been amended by two amendments "EN 10077-1:2006/AC:2009" and "EN 10077-1:2006/AC2:2009". The combined document contains a base identifier and one or more supplement identifiers. e.g. "ISO/IEC DIR 1:2022 + IEC SUP:2022" means that the document combines document "ISO/IEC DIR 1:2022" with its supplement of "ISO/IEC DIR 1:2022/IEC SUP:2022".
* supplement: pubid '/' pubid means that a document is a "supplement to" another document. e.g. "EN 10077-1:2006/AC:2009" means that the document EN 10077-1:2006 has been supplemented by the document AC:2009. e.g. "ISO 8601-1:2019/Amd 1:2024" means that this is the amendment 1 to the document ISO 8601-1:2019. It contains a base identifier. e.g. "ISO/IEC DIR IEC SUP" means that the document is a supplement to the document "ISO/IEC DIR" and called the "IEC SUPPLEMENT". The document type is not specified but being part of the DIR it is a Directive Supplement.
* dual published pubid: pubid '|' pubid means that a document is dual published by two different organizations. e.g. "ISO 5537|IDF 26" or "ISO 5537 | IDF 26" means that the document is published by both ISO and IDF. This document identifier contains two base identifiers.
* multi-publisher pubid: "ISO/IEC WD TS 25025" means the document is published by both ISO and IEC. It is at WD stage (Working Draft) and has document type of TS (Technical Specification). The docnumber is 25025. e.g. "ISO/IEC/IEEE 8802-1AR" means that the document is published by ISO, IEC and IEEE. The docnumber is 8802 with part 1AR. The document type is not specified, so it is a standard.
* adoption pubid: "BS EN ISO/IEC 80079-34:2020" means the "EN ISO/IEC 80079-34:2020" document (base identifier) has been adopted by BSI as a BS (British Standard) document. Furthermore, the "EN ISO/IEC 80079-34:2020" document is a European Standard (EN) adopted by CEN from "ISO/IEC 80079-34:2020", which is the base identifier. The "ISO/IEC 80079-34:2020" is then a multi-publisher pubid, as it is published by both ISO and IEC. The document type is not specified, so it is a standard.
* document types: some pubid schemes place document types in the beginning and some supplements have them at the end. For example, "BS EN IEC 62115:2020+A11:2020 ExComm" means that the document identifier is of an "Expert Commentary" (doctype), based on the document "BS EN IEC 62115:2020+A11:2020" (its base identifier). The document "EN IEC 62115:2020+A11:2020" is a European Standard (EN) adopted by CENELEC from "IEC 62115:2020" (because IEC does not do combined documents, and CEN and CENELEC share the same "EN" prefix for European Norms where CENELEC can adopt from IEC and CEN can adopt from ISO), which is the base identifier.

Notes:

* doctypes: "CEN/CLC Guide 32:2016" means that the document is a guide published by CEN and CENELEC (CLC prefix). The docnumber is 32 and the edition is 2016. The document type is specified as a guide.
* edition and language: "ISO/IEC/IEEE 8802-22:2015 ED1/Amd 2:2017(en)" means that the document is published by ISO, IEC and IEEE. The docnumber is 8802 with part 22. The edition is 1 and the language is English (en). This document is the amendment 2 published in 2017 in English, which contains a base identifier "ISO/IEC/IEEE 8802-22:2015 ED1".

Always use parslet do the parsing, avoid using regexes or prefix matching.

In Ruby, you should support the algebra by applying those math-style operators, e.g. creating a combination ID is 'pubid + pubid' (but raise if the supplement itself does not have the base pubid as its base, etc). Make it easy to use and understand. Know that the algebra across flavors is similar (similar models) but the rendering syntax can be different.

Remember that the supplement or combined pubids "contain" other document identifiers, and the base identifiers do not contain them. You need to update some code that current "contain" supplement (add, cor) etc identifiers.

## Grammar Definition DSL

Work out and write out the algebra and types of identifiers for every flavor in its README.adoc file. Each pubid flavor has an extensive list of pubids being tested.

Devise a grammar definition DSL (language) to describe for each flavor their types of identifiers. and write that in a separate file called `pubid-lang.adoc`

Each parsed object defined in the grammar correspond to a Ruby class.
