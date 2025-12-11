## Important IEEE information

In IEEE, we have to distinguish between "approved/unapproved draft" and "approved standards".

Look at this reply from "PG" (IEEE staff):

1. What does “Active” mean in an identifier?

"IEEE Active Unapproved Draft Std IEEE PC37.06/D8.3, July 2007”

Is the canonical form of this just:
"IEEE Unapproved Draft IEEE PC37.06/D8.3, July 2007”

PG==> Active means there has not been anything to supercede it, as in a second draft or the published standard.

2. What does “Approved Draft Std” mean? Is it different from “Approved Std” (but with a D number)?

e.g.

IEEE Approved Draft Std P1234 / D12, Feb 2007
IEEE Approved Draft Std P277/D2 - Mar 2007
IEEE Approved Draft Std P48/ D5.4, Apr 2009
IEEE Approved Std P1512.4/rev44, Sep 2006
IEEE Approved Std P1609.3/D23, Feb 2007
IEEE Approved Std P277D1/Jan 2007

PG==> The approved draft is the one that was approved by the standards board but has not yet been published. They should not include Std.

3. The big question. What is the canonical format for a document identifier that is an IEEE draft but with an ISO/IEC stage?

There is a dilemma here because ISO/IEC identifiers do not use the “P” prefix for drafts. But IEEE identifiers do not use ISO/IEC stages.

e.g.

ISO/IEC/IEEE P26511.2_FDIS 2018
=> In the ISO format, it would be “ISO/IEC/IEEE FDIS 26511:2018” (they don’t have a way to express P and the “FDIS for 2nd edition”)
=> In the IEEE format, it would be “ISO/IEC/IEEE P26511/Dx-2018” where X is a number that we don’t know

IEEE Unapproved Draft Std P16326:2008/CD2, Sep 2008
=> In the ISO format, it would be “ISO/IEC/IEEE CD2 16326:2008” (I had to search to find out the correct prefix, and ISO does not have a way to express P)
=> In the IEEE format, it would be “ISO/IEC/IEEE P26511/Dx-2008” where X is a number that we don’t know

PG==> That really depends on if it's a joint development (and who's publishing it) or if it's an adoption (and by whom). So the answer seems to be that they should be treated differently. If that doesn't make sense, I might have to refer you to somebody else.

Document this in the plan to handle.


How about we adopt the Typed Stage concept from ISO?

We also have to handle IEEE codeveloped standards with ISO and IEC and ISO/IEC, where the documents can be Draft P ("P" is for "Project", a published standard no longer has a "project", only for drafts), and the draft document can be both assigned an ISO/IEC draft typed stage (e.g. "CD", "DIS") and also an IEEE Draft P number (approved draft, unapproved draft). How do we handle in an architectually clean and sound manner? There is no equivalnece of draft stages, an ISO/IEC CD is not the same as an IEEE Unapproved Draft P and can be in any order.

SO:
* IEEE has drafts of stages (numbered "Pxxx", means Project xxx which is a draft): Unapproved Draft, Approved Draft ("Approved Draft Std" is wrong as said by PG), "Approved Std"
* IEEE published documents with no prefix

