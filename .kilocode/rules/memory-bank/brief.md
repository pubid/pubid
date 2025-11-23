Pubid is a Ruby gem that parses and generates unique public identifiers (PubID)
for published objects such as standards, documents, datasets, and other digital
content.

The PubID project promotes the use of interoperable identifiers across various
domains, including ISO, IEC, NIST, ITU-T, IEEE, CEN, JIS, CCSDS, ANSI, PLATEAU
and more.

The core of PubID is an identifier information model that allows a publisher to
build a human- and machine-readable identification scheme for the unique
identification of documents, standards, and other resources.

This identification scheme is designed to facilitate interoperability and data
exchange between systems and organizations by providing a consistent way to
identify, reference and utilize these resources.

A PubID typically incorporates various components, such as a mixture of an
organizational prefix, document type, document stage, edition or version number,
and other relevant information.

The key feature that a PubID provides is the ability to represent identifiers in
a structured format that can be easily parsed and understood by both humans and
machines, in a round-trippable manner.

Currently, Pubid is being rewritten to improve its architecture and usability.

* The old version of Pubid is available under `gems/pubid-{flavor}` (currently
  namespaced as Pubid)

* The new version of Pubid is available under `lib/pubid_new/{flavor}`
  (currently namespaced as PubidNew)

* Our goal now is to completely replace the old version with the new version in the near
  future, and delete the old folder of `gems` entirely, and rename `pubid_new` to `pubid` (namespace PubidNew => Pubid).

