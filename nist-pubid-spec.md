Publication Identifier Syntax for
NIST Technical Series Publications
Information Services Office
Management Resources
April 2022
Abstract
This document describes the final publication identifier (PubID) syntax used to uniquely identify
all instances of a NIST Technical Series publication.
Keywords
NIST Technical Series publications; publishing; unique identifiers.
Acknowledgments
The authors – Katelynd Bucher, Jim Foti, and Kathryn Miller – would like to thank our NIST
colleagues who reviewed earlier drafts of this proposal and provided useful feedback. We also
thank Ronald Tse of Ribose, Inc., for his interest in NIST publications and suggestions for
improving NIST’s approach to developing and publishing its Technical Series publications.
i
Table of Contents
1 Introduction ............................................................................................................ 1
1.1 Purpose .......................................................................................................... 1
1.2 Scope .............................................................................................................. 1
2 Publication Identifier Syntax ................................................................................. 1
2.1 PubID Elements .............................................................................................. 1
2.1.1 Publisher .............................................................................................. 2
2.1.2 Series ................................................................................................... 2
2.1.3 Report Number ..................................................................................... 2
2.1.4 Part ....................................................................................................... 3
2.1.5 Edition .................................................................................................. 3
2.1.6 Stage .................................................................................................... 4
2.1.7 Update .................................................................................................. 4
2.1.8 Translation ............................................................................................ 5
2.2 PubID Formats ................................................................................................ 5
2.2.1 Human-Readable PubID ...................................................................... 5
2.2.2 Machine-Readable PubID .................................................................... 6
2.2.3 Other PubID Formats ........................................................................... 6
2.3 PubID Examples ............................................................................................. 7
Appendix A— NIST Technical Series and Abbreviations .......................................... 9
A.1 Series Abbreviations ....................................................................................... 9
A.2 Special Publications Subseries ..................................................................... 10
A.3 Part Type Definitions ..................................................................................... 10
A.3.1 Part ..................................................................................................... 10
A.3.2 Volume ............................................................................................... 10
A.3.3 Section ............................................................................................... 11
A.3.4 Supplement ........................................................................................ 11
A.3.5 Index ................................................................................................... 11
A.4 Stage Definitions ........................................................................................... 11
A.4.1 Work-in-Progress Draft (WD) ............................................................. 12
A.4.2 Preliminary Draft (PRD) ...................................................................... 12
A.4.3 Public Draft (PD)................................................................................. 13
A.4.4 Final Publication ................................................................................. 13
ii
1 Introduction
1.1 Purpose
This document describes a publication identifier (PubID) syntax– like those used by Standards
Developing Organizations (SDOs) – that will facilitate simple, unique, and unambiguous publication
referencing. The syntax can accommodate a variety of parameters that currently exist in existing
NIST Technical Series publications and includes a structure that is flexible and can meet the future
needs of additional series and document development models.
1.2 Scope
This PubID syntax shall be applied to all new NIST Technical Series publications starting April
2022. The PubID will be used on cover pages, filenames, and DOIs. The PubID syntax may be
applied to NIST Technical Series publications published before April 2022 on a case-by-case basis
as determined by the NIST Information Services Office (NIST ISO).
The two PubID formats described in Section 2.2—Human-Readable PubID and Machine-Readable
PubID—will be used by the NIST ISO in specific contexts. Authors and other organizations may use
variations of these identifiers, but that is outside of this document’s scope.
2 Publication Identifier Syntax
This section identifies the NIST Technical Series publications PubID syntax, including elements,
structure, and examples.
2.1 PubID Elements
The PubID consists of the following elements:
• Optional elements are in brackets [ ].
• Alternatives are separated with a vertical bar |.
• Parentheses ( ) indicate element groupings.
• Quotation marks ″″ and braces { } identify allowed values.
In the (Human-Readable) examples, the underlined text highlights the element being described. See
Sec. 2.3 for examples of both Human-Readable and corresponding Machine-Readable PubIDs.
1
2.1.1 Publisher
<publisher> = ″NIST″ | ″NBS″
Description: The <publisher> element is REQUIRED. It identifies the publisher of the
document at the time it was published.
Scope Note: Refer to the document to identify the correct publisher name. Generally
speaking, use ″NIST″ for 1988-present, and ″NBS″ for 1901-1988.
Example: NIST TN 2067
2.1.2 Series
<series> = ″AMS″ | ″BH″ | ″BMS″ | … | ″TN″ | ″TTB″
Description: The <series> element is REQUIRED. It identifies the publication’s NIST
series.
Scope Note: See Appendix A.1 for the current list of series abbreviations.
Example: NIST SP 1500-7r2
2.1.3 Report Number
<report-num> = ( <sequence-num> |
( <subseries-num> [<subseries-id>]″
-
″<sequence-num>) )
<sequence-num> = {0-9} ; integer
<subseries-num> = {0-9} | yyyymmdd
<subseries-id> = ″GB″ ; GB used for SP 1190 Guide Briefs
Description: The <report-num> element is REQUIRED. It identifies a report’s position
within a series or subseries. The <sequence-num> is an integer. The subseries number
(<subseries-num>) may be an integer or a date, depending on the series.
Scope Note: See Appendix A.2 for the current list of subseries and each one’s subseries
number (<subseries-num>). Currently, the only subseries with a <subseries-id> are
the SP 1190 Guide Briefs, SP 1190GB.
Examples:
NIST SP 1190GB-12 NIST SP 1500-1 NIST CSWP 20200204-7
2
2.1.4 Part
<part> = [<part-id>] ( [<part-type>][<part-id>] )
<part-id> = {A-Z0-9} ; Uppercase letters, and numbers
<part-type> = ″pt″ | ″v″ | ″sec″ | ″sup″ | ″indx″
Description: The <part> element is OPTIONAL. Each occurrence of <part-id> and
<part-type> can appear no more than once.
Scope: Sometimes a <part-id> consists only of an uppercase letter that follows
<report-num>. Usually, a <part-type> is identified as a “Part” (″pt″), “Volume”
(″v″), “Section” (″sec″), Supplement (″sup″), or Index (″indx″). In rare instances, a
<part> may consist of two part identifiers. See A.3 for descriptions of the different
<part-type> values.
Examples:
NIST SP 800-137A NIST SP 800-57pt3 NIST IR 8011v3
NBS NSRDS 3sec11 NIST SP 955sup2010 NBS NSRDS 63indx
NIST IR 8183Av1
2.1.5 Edition
<edition> = <edition-type><edition-id>
<edition-type> = ″
-
″ | ″e″ | ″r″
<edition-id> = {1-9} | yyyy
Description: If the <edition> is present, then both <edition-type> and <edition-
id> are REQUIRED. The <edition-id> may consist of a whole number or a year.
Editions are published according to NIST procedure PR 1502.01.
Scope: The hyphen ″
-
″ <edition-type> may only be used for publications with
historical precedent (e.g., NIST FIPS 201-3, NIST SP 800-73-4). Otherwise, indicate that it’s
an “edition” (″e″) or “revision” (″r″). Typically, editions use a year value (yyyy) for
<edition-id>. If an existing publication indicates it’s a “version”, it’s PubID should use
the “revision” <edition-type>.
Examples:
NIST FIPS 201-3 NIST IR 7383e2013 NIST SP 800-53Ar5
3
2.1.6 Stage
<stage> = <stage-id><stage-type>
<stage-id> = “i” | “f” | {2-9} ; ″i″
<stage-type> = ″wd″ | ″prd″ | ″pd″
,″f″, and positive integers
Description: If the publication is a Draft, the <stage> element is REQUIRED. If the
publication is Final, then the <stage> element is OMITTED. When the <stage> element is
present, it consists of a <stage-type> preceded by a <stage-id>.
Scope: The most commonly used <stage-type> is “public draft” (″pd″); most
occurrences will be an “initial” or “first” public draft, where <stage> = ipd .
Occasionally there are pubs identified specifically as a “final public draft” where <stage>
= fpd . Other drafts subsequent to an initial draft will have a sequential number, 2pd,
3pd…
These <stage-type> fields are used most frequently for publications from the Information
Technology Laboratory’s Computer Security Division and Applied Cybersecurity Division.
For explanations, see Appendix B.
Examples:
NIST SP 1800-90 iwd NIST SP 800-140Cr1 ipd 2.1.7 Update
NIST SP 1800-33 iprd
NIST IR 9072 2pd NIST SP 800-37r2 fpd
<update> = <update-type><update-id>
<update-type> = ″upd″
<update-id> = {1-9} ; positive integers
Description: If the publication is an update (published according to NIST procedure PR
1502.01), then the <update> element is REQUIRED. When the <update> element is
present, it consists of an <update-type> followed by an <update-id>.
Scope: Currently, the only <update-type> is ″upd″. The first update of a publication has
<update-id> of ″1″
, resulting in <update> = upd1. If subsequent updates are
published, the <update-id> increases incrementally. For historical FIPS that included a
“Change Notice”, those are now considered “updates” and simply use the ″upd″ <update-
type>.
Examples: NIST SP 800-53B-upd1 NIST FIPS 202-upd1 ipd
4
2.1.8 Translation
<translation> = {aaa} ; ISO 639-2 three-letter language code
Description: If the publication is in a language other than English, then the
<translation> element is REQUIRED. The publication’s language is indicated using a
three-letter ISO 639-2 language code. If a language specifies multiple codes (e.g., French),
use the bibliographic “(B)” code (e.g., “fre” for French).
Scope: These translation language codes will differ from the language codes used in DOIs
before the implementation of this PubID syntax (e.g., pt  por; es  spa, etc.).
Examples:
NIST SP 800-181r1 por NIST CSWP 20180416 ara
NIST IR 8119 vie 2.2 PubID Formats
The NIST ISO will use the PubID in two formats: a Human-Readable PubID and Machine-Readable
PubID. They comprise the same PubID structure but use different characters to separate the PubID
elements.
2.2.1 Human-Readable PubID
The NIST ISO will use the Human-Readable PubID in NIST Technical Series publications:
• on cover pages and title pages
• in reference lists
• in publication listings on NIST websites
Human-Readable PubID
<publisher> <series> <report-num>[<part>][<edition>][-<update>] [<stage>] [<translation>]
Example: NIST HB 150-1e2021-upd3 ipd spa
5
2.2.2 Machine-Readable PubID
The NIST ISO will use the Machine-Readable PubID to construct:
• digital object identifiers (DOIs)
• publication filenames
Machine-Readable PubID
<publisher>.<series>.<report-num>[<part>][<edition>][-<update>][.<stage>][.<translation>]
Example: NIST.HB.150-1e2021-upd3.ipd.spa
2.2.3 Other PubID Formats
This specification does not preclude the use of other formats by NIST or external organizations, nor
does it require NIST authors to use these PubIDs within specific contexts. One example format that
has been proposed previously is a “full format,” e.g., “NIST Special Publication (SP) 800-53
Revision 5 Update 1”, which would correspond to Machine-Readable PubID NIST.SP.800-53r5-
upd1. Such formats may be used by others but are outside the scope of this specification.
6
2.3 PubID Examples
Table 1 shows examples of how this PubID could be applied to some existing publications.
Table 1: Example Implementations of the NIST Technical Series publications PubID
<publisher> <series> <report- num> [<part>] [<edition>] [<update>] [<stage>] [<translation>] Human Readable PubID Machine Readable PubID
NIST TN 2500 NIST TN 2500 NIST.TN.2500
NIST AMS 600-9 NIST AMS 600-9 NIST.AMS.600-9
NIST SP 800-90 B NIST SP 800-90B NIST.SP.800-90B
NIST IR 8011 v3 NIST IR 8011v3 NIST.IR.8011v3
NIST IR 8183 Av1 NIST IR 8183Av1 NIST.IR.8183Av1
NIST NCSTAR 1-1 Cv1 NIST NCSTAR 1-1Cv1 NIST.NCSTAR.1-1Cv1
NBS NSRDS 3 sec9 NBS NSRDS 3sec9 NBS.NSRDS.3sec9
NIST TN 2135 sup NIST TN 2135sup NIST.TN.2135sup
NIST SP 964 indx NIST SP 964indx NIST.SP.964indx
NIST SP 800-57 pt1 r5 NIST SP 800-53pt1r5 NIST.SP.800-57pt1r5
NIST SP 800-40 r3 NIST SP 800-40r3 NIST.SP.800-40r3
NIST SP 922 e2020 NIST SP 922e2020 NIST.SP.922e2020
NIST HB 150-6 e2020 NIST HB 150-6e2020 NIST.HB.150-6e2020
NIST SP 800-188 2pd NIST SP 800-188 2pd NIST.SP.800-188.2pd
NIST SP 800-53 r5 fpd NIST SP 800-53r5 fpd NIST.SP.800-53r5.fpd
NIST IR 8204 upd1 NIST IR 8204-upd1 NIST.IR.8204-upd1
7
<publisher> <series> <report- num> [<part>] [<edition>] [<update>] [<stage>] [<translation>] Human Readable PubID Machine Readable PubID
NIST FIPS 140-2 upd2 NIST FIPS 140-2-upd2 NIST.FIPS.140-2-upd2
NIST SP 800-53 r4 upd3 NIST SP 800-53r4-upd3 NIST.SP.800-53r4-upd3
NIST SP 800-53 A r4 upd1 NIST SP 800-53Ar4-upd1 NIST.SP.800-53Ar4-upd1
NIST SP 800-60 v1 r1 NIST SP 800-60v1r1 NIST.SP.800-60v1r1
NIST SP 800-57 pt1 r4 NIST SP 800-57pt1r4 NIST.SP.800-57pt1r4
NIST SP 800-73 -4
(historical
precedent)
upd1 NIST SP 800-73-4-upd1 NIST.SP.800-73-4-upd1
NIST SP 800-85 B -4
ipd NIST SP 800-85B-4 ipd NIST.SP.800-85B-4.ipd
(historical
precedent)
NIST SP 1800-13 B 2pd NIST SP 1800-13B 2pd NIST.SP.1800-13B.2pd
NIST SP 1800-19 B iprd NIST SP 1800-19B iprd NIST.SP.1800-19B.iprd
NIST IR 8228 spa NIST IR 8228 spa NIST.IR.8228.spa
8
Appendix A—NIST Technical Series and Abbreviations
A.1 Series Abbreviations
Series descriptions are maintained on the NIST Information Services Office website.
AMS Advanced Manufacturing Series
BH Building and Housing
BMS Building Materials and Structures Reports
BSS Building Science Series
CIRC NBS Circulars
CS Commercial Standards
CSM Commercial Standards Monthly
CSWP NIST Cybersecurity White Papers
EAB Economic Analysis Briefs
FIPS Federal Information Processing Standards Publications
GCR Grantee/Contractor Reports
HB Handbooks
IR NISTIR
MONO Monographs
MP Miscellaneous Publications
NCSTAR NSRDS National Construction Safety Team Act Reports
National Standard Reference Data Series
OWMWP Office of Weights and Measures White Papers
PC Photographic Laboratory Circulars
RPT National Bureau of Standards Reports
SIBS Special Interior Ballistic Studies
SP Special Publications
TIBM Technical Information on Building Materials for Use in the Design of Low
Cost Housing
TN Technical Notes
TTB Technology Transfer Briefs
9
A.2 Special Publications Subseries
The Special Publications series consists of these additional subseries:
SP 250 SP 260 SP 300 SP 400 SP 480 SP 500 SP 700 SP 800 SP 823 SP 960 SP 1190GB SP 1200 SP 1500 SP 1800 SP 1900 SP 2000 SP 2100 Special Publication Subseries: Calibration Services
Special Publication Subseries: Standard Reference Materials
Special Publication Subseries: Precision Measurement and Calibration
Special Publication Subseries: Semiconductor Measurement Technology
Special Publication Subseries: Law Enforcement Technology
Special Publication Subseries: Computer Systems Technology
Special Publication Subseries: Industrial Measurement Series
Special Publication Subseries: Computer Security
Special Publication Subseries: Integrated Services Digital Network Series
Special Publication Subseries: NIST Recommended Practice Guides
Special Publication Subseries: 1190 Guide Briefs
Special Publication Subseries: Protocols
Special Publication Subseries: Working Group Papers
Special Publication Subseries: NIST Cybersecurity Practice Guides
Special Publication Subseries: Cyber-Physical Systems
Special Publication Subseries: Standards Coordination
Special Publication Subseries: Conference Proceedings
A.3 Part Type Definitions
Section 2.1.4 identifies five <part-type> values. Associated <part-type> values are linked
by a shared <report-num>. One <report-num> can have multiple <part-type> values.
A.3.1 Part
<part-type> = pt
Description: A self-contained document that is linked to other self-contained documents within a
series, and along with those linked documents, makes up a larger whole. A part may be
published alongside other parts within a volume. Each part may or may not have a unique title.
A.3.2 Volume
<part-type> = v
Description: A document that is part of a larger collection. May be used to combine parts and|or
10
sections, split large documents for ease of reading, or as an identifier for a sequence of
documents. Each volume may or may not have a separate title.
A.3.3 Section
<part-type> = sec
Description: a subdivision of a document, also known as a chapter. It is published as a stand-
alone document but is not self-contained. May be used to split large documents for ease of
reading or to present to different audiences. Each section should have a unique title.
A.3.4 Supplement
<part-type> = sup
Description: additional information that supports a document or collection of documents, also
known as an appendix. It is published as a stand-alone but is not self-contained. A supplement
should use the title of the document or collection of documents it is supporting.
A.3.5 Index
<part-type> = indx
Description: a list of words and/or phrases and locations where related information can be found
in a document or collection of documents. It is published as a stand-alone but is not self-
contained. An index should use the title of the document or collection of documents it is
supporting.
A.4 Stage Definitions
Section 2.1.6 describes how to specify different stages of draft publications (i.e., they have not
been published as “final”). These typically are not entered in NPS, but they are often assigned
DOIs and uploaded to the NIST Library’s publications server. They are also occasionally
referenced by other, final publications. Therefore, the PubID can be composed to identify these
draft publications.
NIST’s Computer Security Division and Applied Cybersecurity Division use the following
stages in their publication development process. Not every publication goes through every stage.
Some are published only as “final” publications, but the vast majority are first issued as an Initial
Public Draft (typically just referred to as a “Public Draft”) and then a Final publication.
The National Cybersecurity Center of Excellence (NCCoE) has been experimenting with a new
agile publication development process for some of their multi-volume SP 1800 series documents,
and they created the “Work-in-Progress” and “Preliminary Draft” stages to support this effort.
These are more informal draft stages during early development that precede the release of any
full, initial public draft (IPD) for public comment. These stages are not prescriptive. Other
divisions and OUs at NIST may or may not choose to use them.
11
A.4.1 Work-in-Progress Draft (WD)
<stage-type> = wd
<stage-id> = i | 2 | 3 |…| f
A work-in-progress draft (WD) indicates that the document is currently under development.
A WD is not yet complete, and organizations should not attempt to implement it. The content is
in an early stage of development – rough, incomplete, and experimental. It has not been
extensively edited or vetted. This provides an insider view of the development of the content and
gives NIST an opportunity to share early thoughts, ideas, and approaches with the community.
NIST welcomes early informal feedback and comments, which will be adjudicated after the
specified public comment period.
There will be one or more versions of the content before it is graduated to a preliminary draft
(PRD) status.
The initial WD has <stage> = iwd. Any subsequent WDs will have <stage> = 2wd | 3wd
|… .
A.4.2 Preliminary Draft (PRD)
<stage-type> = prd
<stage-id> = i | 2 | 3 |…| f
After the comments of a work-in-progress draft (WD) have been collected and adjudicated, a
preliminary draft (PRD) is produced.
A PRD is more cohesive and composed of a complete, logical grouping of sections or a volume.
The content is considered to be stable, but changes are expected to occur. There are gaps in the
content, and the overall document is still incomplete. NIST welcomes early informal feedback
and comments, which will be adjudicated after the specified public comment period.
Organizations may consider experimenting with guidelines with the understanding that they will
identify gaps and challenges.
There will be one or more versions of the content before it is graduated to a public draft (PD)
status.
The initial PRD has <stage> = iprd. Any subsequent PRDs will have <stage> = 2prd |
3prd |… .
12
A.4.3 Public Draft (PD)
<stage-type> = pd
<stage-id> = i | 2 | 3 |…| f
The most commonly used public comment document at NIST is the Public Draft (PD)—and
specifically the Initial (first) Public Draft (IPD).
A Public Draft is a complete document that is posted on a NIST website for a specific public
comment period, during which reviewers may submit comments (e.g., technical and editorial) to
NIST via email. For NIST IRs, TNs, SPs, the comment period is typically 30, 45, or 60 days;
FIPS comment periods are typically 90 days or longer.
Authors review all comments received, make appropriate changes to the document, and
determine whether to proceed with a subsequent Public Draft (to obtain more public input) or—
more commonly—a Final publication.
The initial PD has <stage> = ipd. Any subsequent PDs will have <stage> = 2pd | 3pd
|… . There are some cases where the authors may specifically designate a PD as a Final Public
Draft (FPD). The FPD provides one last public comment period and may be especially important
for publications that significantly impact stakeholders. An FPD stage is typically planned from
the beginning of the publication development process. The comment period is typically shorter
than any other comment period. The Final Public Draft has <stage> = fpd.
A.4.4 Final Publication
<stage-type> (Not Applicable)
A Final publication has been reviewed and approved by ERB and is published by the NIST
Library. It may or may not have had draft stages.
No <stage> is included in the PubID for the Final publication.
13