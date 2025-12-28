Publication Identifier Syntax for
NIST Technical Series Publications
Information Services Office
Management Resources
August 2021
PROPOSAL PUBLICATION ID SYNTAX FOR
AUGUST 2021 NIST TECH SERIES PUBS
Abstract
This document identifies challenges in uniquely identifying all editions of a NIST Technical Series
publication and proposes a publication identifier (PubID) syntax that can accommodate all variants
of all series.
Keywords
NIST Technical Series publications; publishing; unique identifiers.
Acknowledgments
The authors – Katelynd Bucher, Jim Foti, and Kathryn Miller – would like to thank our NIST
colleagues who reviewed earlier drafts of this proposal and provided useful feedback. We also
thank Ronald Tse of Ribose, Inc., for his interest in NIST publications and suggestions for
improving NIST’s approach to developing and publishing its Technical Series publications.
Comments on this proposal should be submitted to techpubs@nist.gov (Subject:
“Publication ID Proposal”) by September 30, 2021.
ii
PROPOSAL PUBLICATION ID SYNTAX FOR
AUGUST 2021 NIST TECH SERIES PUBS
Table of Contents
1 Introduction ............................................................................................................ 1
1.1 Problem Statement ......................................................................................... 1
1.2 Purpose of this Proposal ................................................................................. 1
1.3 Scope .............................................................................................................. 1
1.4 Document Structure ........................................................................................ 2
2 Current Challenges ................................................................................................ 2
2.1 2.2 Negative Impacts of the Current Approach ..................................................... 2
International SDO Publication Identifiers as a Starting Point .......................... 2
2.2.1 Overview of PubIDs for ISO, IEC, and ISO/IEC Publications ............... 2
2.2.2 Differences Between ISO and IEC Publications and NIST Technical
Series publications .......................................................................................... 4
2.3 Potential Benefits ............................................................................................ 4
3 Publication Identifier Syntax Proposal ................................................................. 5
3.1 Objectives ....................................................................................................... 5
3.2 Proposed PubID Syntax .................................................................................. 5
3.3 PubID Examples ........................................................................................... 10
4 Next Steps ............................................................................................................ 12
Appendix A— Example NIST Special Publication (Informative).............................. 13
A.1 NIST Special Publication 800-53 .................................................................. 13
A.2 Applying the Proposed PubID Syntax ........................................................... 15
Appendix B— Publication Stages .............................................................................. 16
B.1 Stages Defined in NIST PR 1502.01 ............................................................. 16
B.2 Stages Used by NIST’s Computer Security Division and Applied
Cybersecurity Division (Informative) ...................................................................... 16
iii
PROPOSAL PUBLICATION ID SYNTAX FOR
AUGUST 2021 NIST TECH SERIES PUBS
1 Introduction
1.1 Problem Statement
Although many NIST Technical Series publications are sufficiently identified by a sequential
report number, documents that persist and change over time or have multiple parts and updates
need unique identifiers to convey additional information. These identifiers must accommodate a
variety of document stages (e.g., draft, final), editions, parts, updates, and translations.
Currently, most NIST Technical Series publications lack a structured publication identifier
(PubID) that can concisely and unambiguously identify each instance of a document. This can
lead to users referencing the document in ways that are verbose, inconsistent, incomplete, or
ambiguous. It can also hinder reference automation, which relies on the ability to uniquely
identify publications.
1.2 Purpose of this Proposal
This document proposes a syntax – like those used by Standards Developing Organizations
(SDOs) – that will facilitate simple, unique, and unambiguous publication referencing. The
syntax can accommodate a variety of parameters that currently exist in identifiers across existing
NIST Technical Series publications and includes a structure that is flexible and can meet the
future needs of additional series and document development models.
In addition to proposing this syntax, the authors offer some ideas for engaging with stakeholders
to obtain feedback and support for implementing such a change.
1.3 Scope
This problem has affected NIST Technical Series publications for some time, although it was
most recently identified during new publication work in the Information Technology
Laboratory’s (ITL) Computer Security Division (CSD). CSD leads the development of the NIST
Special Publication 800 series, “Computer Security.” Documents in that series were downloaded
from NIST servers more than four million times in Fiscal Year (FY) 2019. Currently, it is
challenging to uniquely and unambiguously refer to SP 800 publications in a consistent manner,
particularly those that have multiple additions, parts, and updates. Although the immediate focus
of this proposal is to address issues in the SP 800 series, this PubID syntax can be applied to all
NIST Technical Series publications.
The NIST Information Services Office (“NIST Library”) – the publisher of NIST Technical
Series publications – has internally defined a syntax for creating digital object identifiers (DOIs).
However, DOIs serve a different purpose than a PubID. DOIs provide perpetual access, and
while they are unique, they are not meant to uniquely identify a single instance of a publication.
For example, DOIs do not differentiate between different “errata updates” of a specific
publication edition. See Appendix A for an example of how this applies to the SP 800 series.
1
PROPOSAL PUBLICATION ID SYNTAX FOR
AUGUST 2021 NIST TECH SERIES PUBS
1.4 Document Structure
This document is organized as follows:
• Section 2 – Current Challenges
• Section 3 – Publication Identifier Syntax Proposal
• Section 4 – Next Steps
2 Current Challenges
2.1 Negative Impacts of the Current Approach
If NIST does not provide a single PubID for a document, this can lead to:
• Users creating their own syntax for uniquely identifying a publication;
• Ambiguous identification, such that different editions or updates of a publication – whose
requirements may differ – could be confused with one another;
• Verbose identifiers that take up an inordinate amount of space, are inconvenient to
reference, and can hinder the adoption of automated citation management;
• Inconsistent identifiers issued over a long period of time for different editions of a
publication;
• NIST Technical Series publications used across various NIST organizational units (OUs)
with a variety of potentially conflicting identifiers; and
• Stakeholders being presented with a potentially baffling array of unstructured PubIDs –
sometimes even within a specific series – and having an inconsistent experience.
2.2 International SDO Publication Identifiers as a Starting Point
NIST’s current approach to identifying Technical Series publications is not consistent with the
practice of SDOs. Additionally, NIST’s current approach can make it difficult for those
standards to precisely reference NIST publications.
2.2.1 Overview of PubIDs for ISO, IEC, and ISO/IEC Publications
The International Organization for Standardization (“ISO”) and International Electrotechnical
Commission (“IEC”) are SDOs whose PubIDs are similar with some minor differences. They
also publish standards jointly as “ISO/IEC” publications and use a syntax for identifying a
publication, its parts (if any), edition (using the publication year), document development stage
(e.g., ISO uses “CD,” “DIS,” “FDIS”1), and corrections (“Cor”) or amendments (“Amd”). Some
of this is described in ISO/IEC Directives, Part 1. ISO and IEC PubIDs generally take the
1 ISO stage codes are documented at https://www.iso.org/stage-codes.html. IEC has a different set – and larger number – of stage
codes at https://www.iec.ch/standardsdev/resources/processes/stage_codes.htm.
2
PROPOSAL PUBLICATION ID SYNTAX FOR
AUGUST 2021 NIST TECH SERIES PUBS
following form:
{publisher ID}[/][{stage}] {series} {report number}[-{part number}]:{year}
The {series} is omitted for ISO and IEC international standards, but it is used for other
publications such as Technical Reports (“TR”). ISO and IEC also differ regarding the {part
number}, which in IEC may also include a subpart (e.g., “IEC 60721-3-1:2018”). Regardless of
these specific differences, their general formats are useful for creating a PubID syntax for
NIST’s Technical Series publications.
Some example ISO and IEC PubIDs include:
• ISO/IEC CD 15408–3 (“Committee Draft of ISO/IEC 15408 Part 3”)
• ISO/CD 22382 (“Committee Draft of ISO 22382”)
• ISO/PRF TR 23455 (“Proof of ISO Technical Report 23455”)
• ISO/IEC 14888-2:2008 (“ISO/IEC 14888 Part 2, 2008 edition”)
Minor corrections and technical amendments are issued as separate documents and are not
incorporated into the original publication. A supplemental document uses the main document’s
PubID and appends information to identify whether it is a Correction or Amendment, a sequence
number, and its year of issue:
• ISO/IEC {series} {stage} {report number}[-{part number}]:{year}/{“COR”|“AMD”}
{number}:{year}
IEC uses a slightly different format:
• IEC {series}[/{stage}] {report number}[-{part number}]:{year}+AMD{number}:{year}
Some examples include:
• ISO 7220:1996/COR 1:2001 (“First correction—issued in 2001—to ISO 7220, 1996
edition”)
• ISO/IEC 18031:2011/AMD 1:2017 (“First amendment—issued in 2017—to ISO/IEC
18031, 2011 edition”)
• IEC 62304:2006+AMD1:2015 (“First amendment—issued in 2015—to IEC 62304, 2006
edition”)
If a publication is formally reviewed after several years and is confirmed without any changes,
the PubID is not altered, as the document itself has not been altered. The confirmation is
indicated elsewhere, such as on the ISO website.
3
PROPOSAL PUBLICATION ID SYNTAX FOR
AUGUST 2021 NIST TECH SERIES PUBS
2.2.2 Differences Between ISO and IEC Publications and NIST Technical Series
publications
Although ISO and IEC publications differ somewhat from NIST Technical Series publications,
the syntaxes described in Section 2.2.1 provide a useful starting point. The PubID syntax adopted
for NIST Technical Series publications will need to account for those differences. Table 1 shows
how NIST Technical Series publications are currently identified and compares them with the
approach used by ISO, IEC, and ISO/IEC publications.
Table 1: Features of Different Publications
Features NIST Technical Series publications
ISO, IEC, ISO/IEC Pubs
(Current Approach)
Series Consist of 12+ different series that
must always be expressed in the
PubID
The {series} is omitted for ISO and IEC
international standards, but it is used for
other publications such as Technical
Reports (“TR”).
Report numbers May consist of only a whole
number, a series number
hyphenated with a sequence
number, or a sequence number
with an alphabetic suffix to indicate
a part
Whole numbers only
Parts and subparts May have various types of named
“parts,” including Part, Volume,
Section, Supplement, Index, etc.
May have multiple “parts” (and
“subparts,” for IEC and ISO/IEC) indicated
by “{report number}-{part number}-
{subpart}”
Edition Typically indicated by Revision,
Version, or Edition and sequential
number or letter; occasionally
indicate the year
Always include the year to indicate the
edition.
Translations Currently indicated by a 2-letter
code
Indicated by a 2-letter code
Updates Errata updates issued as complete,
updated publications, with errata
date indicated on title page below
the original publication date
Corrections and Amendments are
provided as supplemental documents
instead of incorporating changes into the
original publication.
2.3 Potential Benefits
Implementing a defined PubID syntax for NIST Technical Series publications offers a variety of
potential benefits, including:
• Consistency: A single, well-defined approach that is consistent for various technical
publications across NIST
• Uniqueness: A way to guarantee that identifiers – including DOIs – are unique for each
instance of a publication
4
PROPOSAL PUBLICATION ID SYNTAX FOR
AUGUST 2021 NIST TECH SERIES PUBS
• Disambiguation: A clear indication of a publication’s stage, revision, and/or update
status
• Information richness: Ability to include a significant amount of information about the
publication in a single identifier
• Facilitate automation: A well-defined, machine-readable syntax that enables the
automation of publication tracking and reference
• Self-explanatory: A single identifier that conveys information about the publication that
currently needs to be parsed from multiple elements in the document
• Easy citation: Ability to consistently reference specific NIST publications
• Discoverability: Ability to search on a well-structured identifier
3 Publication Identifier Syntax Proposal
This section identifies objectives for introducing a NIST Technical Series publications PubID
syntax and proposes a potential syntax for adoption at NIST.
3.1 Objectives
Some objectives for implementing a PubID syntax include:
• Accommodating elements in existing publication identifiers, including:
o Parts: “Part,” “Volume,” “Supplement,” “Section,” “Index,” etc.
o Editions: “Revision,” “Version,” “Edition,” etc.
o Updates: “errata updates”
o Sequence numbers
o Translations
• Implementing a flexible approach that can easily accommodate the identification of new
series and document development stages (e.g., “initial public draft,” “second public
draft,” etc.);
• Causing no or minimal disruption to existing users of NIST Technical Series publications
o Does not require changes to existing publications
o Can be applied to all NIST Technical Series publications starting at some to-be-
determined date
o Can be applied to existing publication series (e.g., active “final” and “draft” SP
800 series documents), if desired
o Uses syntax and characters that are consistent with the requirements of the
CrossRef service that NIST uses to generate and manage DOI suffixes (e.g., in
addition to alphanumeric characters, CrossRef currently allows “
-
._,()/” but not
“#+:&[]”)
3.2 Proposed PubID Syntax
The proposed PubID consists of the data elements in Table 2.
5
PROPOSAL PUBLICATION ID SYNTAX FOR
AUGUST 2021 NIST TECH SERIES PUBS
Table 2: PubID Data Elements
Element Applies to Comment Examples / Representation
{series} All publications “NIST” followed by a space and
the standard abbreviation of the
series name
Special Publication:
NIST SP
Interagency or Internal
Report:
NIST IR
Handbook:
NIST HB
Technical Note:
NIST TN
{stage} All publications
that are not
final
Omit for final
publications
In many series, documents are
only released as final
publications. Some series (e.g.,
SP 800 and SP 1800) may have
additional levels of document
development (staging), which
can combine the iteration (initial
[I], second [2],…, nth [n], final [F])
with the stage (public draft [PD],
work-in-progress draft [WD],
preliminary draft [PRD]).
The stage code is enclosed in
parentheses (separated from
the series).
Work-in-Progress Draft:
(WD)
Preliminary Draft:
(PRD)
Initial Public Draft:
(IPD)
Second Public Draft:
(2PD)
Final Public Draft:
(FPD)
NOTE: These are possible
stages – not all documents
will use every stage. The
most commonly used stage
will be (IPD). For
descriptions of these stages,
see Appendix B.
6
PROPOSAL PUBLICATION ID SYNTAX FOR
AUGUST 2021 NIST TECH SERIES PUBS
Element Applies to Comment Examples / Representation
{report number} All publications Depending on the series, this
may consist of a {sequence
number}, {subseries}-{sequence
number}, {sequence number}-
{volume}, {sequence number}-
{edition}, {subseries}-{sequence
number}-{edition}, etc.
{sequence number}
NIST TN 2143
{subseries}-{seq. num.}
NIST SP 1200-28
{seq. num.}-{volume}
NIST IR 8011-4
{seq. num.}-{edition}
NIST HB 135-2020
{subseries}-{seq. num.}-
{edition}
NIST SP 800-73-4
{part}
Consists of
{part-type} and/or
{part-id}
Publications
with a specified
part
“Parts” may be identified using a
{part-type},
2 followed by a {part-
id} consisting of Arabic numerals
and/or alphabetic characters (do
not represent numbers using
Roman numerals).
In some situations, the {part-
type} may not be followed by a
{part-id} (e.g., a supplement or
index might simply be identified
using sup or indx).
{part-type} values
Part: pt
Volume: v
Section: sec
Supplement: sup
Index: indx
Examples:
pt1
v2
A
sec5
supA
indx
2 Optional.
7
PROPOSAL PUBLICATION ID SYNTAX FOR
AUGUST 2021 NIST TECH SERIES PUBS
Element Applies to Comment Examples / Representation
{edition}
Consists of
{edition-type} and
{edition-id}
Publications
with a specified
edition
“Editions” are identified using
an {edition-type} followed by an
{edition-id} consisting of Arabic
numerals and/or alphabetic
characters (do not represent
numbers using Roman
numerals)
{edition-type} values3
Edition: e
Revision: r or -
Version: ver
Examples:
e2019
r5
-4
ver2
{translation} Non-English
publications
If the document is a translation
into a language other than
English, apply a three-letter ISO
639-2 code4 enclosed in
parentheses.
Examples:
French: (fre)
Japanese: (jpn)
Portuguese: (por)
Spanish: (spa)
{update} All updated
publications
If a particular edition is updated,
the original edition info will be
followed by “/” and then “Upd”
to indicate “Update.”5 Updated
content is incorporated into the
publication and not as a
separate file.6
{update} values
Update: /Upd
{update number} All updated
publications
Update numbers are indicated
by sequential Arabic numerals,
starting with “1.
”
Examples:
1
2
{year} All updated
publications
The update number is followed
by “
-” and the year of that
update (yyyy).
Examples:
2020
2021
3 Historically, different edition types were indicated by either a dash (‘-’) or alphabetic character (e.g., ‘e’, ‘r’, or ‘ver’). Annual
revisions of publications whose numbers utilized a '-' continue this practice to maintain numbering consistency.
4 See http://www.loc.gov/standards/iso639-2/php/code_list.php.
5 Since a NIST Technical Series publication (“{update}”) is incorporated into the publication, the authors recommend identifying
it using “Upd” instead of “Cor” or “Amd” to avoid confusion with how corrections and amendments are implemented by ISO/IEC.
6 Additional update types could be added in the future, if necessary.
8
PROPOSAL PUBLICATION ID SYNTAX FOR
AUGUST 2021 NIST TECH SERIES PUBS
The proposed PubID syntax takes the following two forms:
Typical document:
{series}({stage}) {report number}{part}{edition}({translation})
Updated document:
{series}({stage}) {report number}{part}{edition}({translation})/{update}{update number}-{update year}
As shown in Table 1, the {part} element consists of {part-type} and/or {part-id}. Similarly,
{edition} consists of {edition-type} and {edition-id}.
9
PROPOSAL PUBLICATION ID SYNTAX FOR
NIST TECH SERIES PUBS
AUGUST 2021 3.3 PubID Examples
Table 3 shows examples of how this PubID syntax could be applied to some existing publications.
Table 3: Example Implementations of the Proposed NIST Technical Series publications PubID Syntax
{series} {stage}
{report
{part}
{edition}
{translation}
{update}
{update
{update
PubID
representation
number}
rep.
rep.
rep.
rep.
number}
year}
(with link to document details)
NIST SP Final 800-40 - Revision 3
r3
- - - - NIST SP 800-40r3
Details
NIST SP Final 800-45 - Version 2
ver2
- - - - NIST SP 800-45ver2
Details
NIST SP Second Public
Draft
2PD
800-188 - - - - - - NIST SP(2PD) 800-188
Details
NIST SP Initial Public
Draft
IPD
800-53 - Revision 5
r5
- - - - NIST SP(IPD) 800-53r5
Details
NIST SP Final 800-53 - Revision 4
r4
- Update
Upd
3 2015 NIST SP 800-53r4/Upd3-20157
Details
NIST SP Final 800-53 Volume A
A
Revision 4
r4
- Update
Upd
1 2014 NIST SP 800-53Ar4/Upd1-20148
Details
NIST SP Final 800-60 Volume 1
v1
Revision 1
r1
- - - - NIST SP 800-60v1r1
Details
NIST SP Final 800-57 Part 1
pt1
Revision 4
r4
- - - - NIST SP 800-57pt1r4
Details
NIST SP Final 800-73 Revision 4
-4
- Update
Upd
1 2016 NIST SP 800-73-4/Upd1-20169
Details
NIST SP Initial Public 800-85 Volume B Revision 4 - - - - NIST SP(IPD) 800-85B-4
7 See Appendix A for a discussion of this example in greater detail.
8 This report number incorporates a part (“A”).
9 This report number incorporates an edition number (“4”).
10
PROPOSAL PUBLICATION ID SYNTAX FOR
AUGUST 2021 representation
NIST TECH SERIES PUBS
{series} {stage}
{report
{part}
{edition}
{translation}
{update}
{update
{update
PubID
number}
rep.
rep.
rep.
rep.
number}
year}
(with link to document details)
Draft
IPD
B -4
NIST SP Second Public
Draft
2PD
1800-13 Volume B
B
- - - - - NIST SP(2PD) 1800-13B
Details
NIST SP Preliminary
Draft
PRD
1800-19 Volume B
B
- - - - - NIST SP(PRD) 1800-19B
Details
NIST IR Final 8011 Volume 3
v3
- - - - - NIST IR 8011v3
Details
NIST IR Final 8204 - - - Update
Upd
1 2019 NIST IR 8204/Upd1-2019
Details
NIST IR Final 8115 - - Spanish
(spa)
- - - NIST IR 8115(spa)
Details
NIST HB Final 130 - 2019 ed.
e2019
- - - - NIST HB 130e2019
Details
NIST SP Final 1041 - Revision 1
r1
- Update
Upd
1 2013 NIST SP 1041r1/Upd1-2013
Details
NIST NCSTAR Final 1-1C Volume 1
v1
- - - - - NIST NCSTAR 1-1Cv1
Details
11
PROPOSAL PUBLICATION ID SYNTAX FOR
AUGUST 2021 NIST TECH SERIES PUBS
4 Next Steps
1. [Completed] Circulate among Computer Security Division and Applied Cybersecurity
Division (CSD/ACD) Management, NIST Library Management, CSD/ACD
representatives to ISO and Internet Engineering Task Force (“ IETF”), NIST Standards
Coordination Office representative, and NIST ERB Chair.
2. 3. 4. 5. [Completed] Update based on feedback.
[Completed] Review by NIST Leadership Board (NLB).
Solicit public comments from stakeholders.
Update based on public feedback.
6. Implementation:
o Advertise and implement for all new NIST Technical Series publications; start
use of PubID on title page and metadata.
o Note: CSD and ACD will apply to title pages and metadata for all existing SP 800
publications and cybersecurity NISTIRs.
12
PROPOSAL PUBLICATION ID SYNTAX FOR
AUGUST 2021 NIST TECH SERIES PUBS
Appendix A—Example NIST Special Publication (Informative)
A.1 NIST Special Publication 800-53
One of the most downloaded of NIST Special Publications is SP 800-53, Security and Privacy
Controls for Federal Information Systems and Organizations. A recent edition was Revision 4,
which had three errata updates – including the latest from January 22, 2015. Figure 1 shows the
title page, which includes the series (“NIST SP”), report number (“800-53”), edition (“Revision
4”), edition date (“April 2013”), and update statement/date (“includes updates as of 01-22-
2015”).
To uniquely identify this publication, the following elements must be combined:
• Series
• Report Number
• Edition OR Edition Date
• Update statement OR Update date
Either “Revision 4” or “April 2013” could be used to identify the edition, but simply using the
edition year, “2013,” might not be helpful since it is possible for different editions of an SP 800
to be issued in the same calendar year. However, for decades, users and stakeholders of SP 800
publications have typically identified different editions using “Revision” or “Rev” instead of the
edition date.
Another uncertainty is whether the complete update statement “includes updates as of 01-22-
2015” should be used or simply the update date, “01-22-2015” or “January 22, 2015.”
A final observation about Figure 1 is that information must be pulled from three separate lines to
uniquely identify this publication.
An author of a different information source who attempts to uniquely reference this document
(800-53) could theoretically use various combinations of data from the title page, such as:
• NIST SP 800-53, Revision 4, includes updates as of 01-22-2015
• NIST SP 800-53 (April 2013), updated January 22, 2015
• NIST SP 800-53, Rev. 4, updated 01-22-2015
Alternatively, they could potentially not notice (or ignore) the update date and insufficiently refer
to the document as “SP 800-53” or “SP 800-53, Revision 4.”
13
PROPOSAL PUBLICATION ID SYNTAX FOR
AUGUST 2021 NIST TECH SERIES PUBS
Figure 1: SP 800-53 Title Page
14
PROPOSAL PUBLICATION ID SYNTAX FOR
AUGUST 2021 NIST TECH SERIES PUBS
A.2 Applying the Proposed PubID Syntax
If the proposed syntax described in Section 3 was applied to this situation, it would result in the
following simple, unambiguous identifier:
NIST SP 800-53r4/Upd3-2015
This PubID could easily be included at the top of the page – possibly enclosed in a border to
improve visual separation from the other text – while keeping other existing fields. Figure 2
shows what the top of the new page would look like:
Figure 2: SP 800-53 Title Page with PubID and Corresponding DOI
Additionally, the PubID could be added to the header or footer of all pages that follow.
15
PROPOSAL PUBLICATION ID SYNTAX FOR
AUGUST 2021 NIST TECH SERIES PUBS
Appendix B—Publication Stages
B.1 Stages Defined in NIST PR 1502.01
NIST Technical Series publications are non-periodical publications published by or for NIST and
intended for internal and public distribution. Descriptions of the Technical Series are provided on
the Library’s webpage. A single NIST Technical Series publication may have multiple stages of
publication, which may include:
1. 2. 3. Draft posted for public comment – A non-final version that is made available to the
public for their input
Final publication – The final version that is made available to the public
Errata update – A new copy of the final publication with corrections made
(corrections made in an errata update may not alter existing requirements or introduce
new technical requirements but rather are intended to remove ambiguity and improve
interpretation of the work)
New revision/edition – A new version of the final publication with significant changes or
updates (examples include updating data to change results, revising guidelines based on
new information, citing new studies, revising content based on reader feedback, etc.)
For more details, see NIST Procedure PR 1502.01, Publishing Multiple Versions of NIST
Technical Series Publications.
4. B.2 Stages Used by NIST’s Computer Security Division and Applied Cybersecurity
Division (Informative)
NIST’s Computer Security Division and Applied Cybersecurity Division use the following
stages in their publication development process. Not every publication goes through every stage.
Some are published only as “final” publications, but the vast majority are first issued as an Initial
Public Draft (typically just referred to as a “Public Draft”) and then a Final publication.
The National Cybersecurity Center of Excellence has been experimenting with a new agile
publication development process for some of their multi-volume SP 1800 series documents, and
they created the “Work-in-Progress” and “Preliminary Draft” stages to support this effort. These
are more informal draft stages during early development that precede the release of any full,
traditional public draft (IPD) for public comment. These stages are not prescriptive and may or
may not be used by other divisions and OUs at NIST.
Work-in-Progress Draft (WD)
A work-in-progress draft indicates that the document is currently under development. This draft
is not yet complete, and organizations should not attempt to implement it. The content is in an
early stage of development – rough, incomplete, and experimental. It has not been extensively
edited or vetted. This provides an insider view of the development of the content and gives NIST
an opportunity to share early thoughts, ideas, and approaches with the community. NIST
welcomes early informal feedback and comments, which will be adjudicated after the specified
16
PROPOSAL PUBLICATION ID SYNTAX FOR
AUGUST 2021 NIST TECH SERIES PUBS
public comment period.
There will be one or more versions of the content before it is graduated to a preliminary draft
status. The content will be hosted on csrc.nist.gov or nccoe.nist.gov, and it will be labeled as
“work-in-progress draft” with a unique version number.
Preliminary Draft (PRD)
After the comments of a work-in-progress draft have been collected and adjudicated, a
preliminary draft is produced. It is more cohesive and composed of a complete, logical grouping
of sections or a volume. The content is considered to be stable, but changes are expected to
occur. There are gaps in the content, and the overall document is still incomplete. NIST
welcomes early informal feedback and comments, which will be adjudicated after the specified
public comment period. Organizations may consider experimenting with guidelines with the
understanding that they will identify gaps and challenges.
There will be one more version of the content before it is graduated to a draft status. The content
will be hosted on csrc.nist.gov or nccoe.nist.gov, and it will be labeled as “preliminary draft”
with a unique version number.
Initial Public Draft (IPD)
The IPD is commonly referred to as “Public Draft.” In order to solicit public feedback on a
document, an IPD is posted on a NIST website for a specific comment period, and reviewers
may submit comments (e.g., technical and editorial) to NIST via email. For NISTIRs and SP
800s, the comment period is typically 30, 45, or 60 days; FIPS comment periods are typically 90
days or longer. Authors review all comments received, make appropriate changes to the
document, and determine whether the next publication stage should be a 2nd Public Draft (2PD)
or – more commonly – a Final publication.
2nd [3rd, etc.] Public Draft (2PD)
If NIST feels that changes to an IPD warrant additional review and comment, a subsequent
comment period may occur, which is typically shorter than the IPD comment period.
Final Public Draft (FPD)
Certain publications may – by default – have an IPD, an FPD, and zero, one, or more public
drafts in-between. The FPD provides one last public comment period and may be especially
important for publications that significantly impact stakeholders. An FPD stage is typically
planned from the beginning of the publication development process. The comment period is
typically shorter than any other comment period.
Final Publication
A Final publication has been reviewed and approved by ERB and is published by the NIST
Library.
17