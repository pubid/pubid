# IEEE Relationship Identifiers - Pattern Analysis

**Created:** 2025-12-11 (Session 122)
**Status:** Architecture Design Phase

---

## Pattern Discovery

From analysis of 1,453 IEEE failures, identified 7 distinct relationship types with ~60-86 identifier gain potential.

---

## Relationship Type Categories

### Category 1: Revision Relationships

**Pattern:** `(Revision of IEEE Std X, IEEE Std Y, ...)`

**Examples:**
```
ANSI C37.45-1981(R1992) (Revision of ANSI C37.45-1969)
IEEE Std 1232-2002 (Revision of IEEE Std 1232-1995, IEEE Std 1232.1-1997, IEEE Std 1232.2-1998)
IEEE P802.11-REVmb/D10.0 (Revision of IEEE Std 802.11-2007, as amended by IEEE Std 802.11k-2008, ...)
```

**Characteristics:**
- Single identifier revises one or more previous standards
- Can include "as amended by" clause for intermediate amendments
- Common in draft P identifiers with `/REV` suffix

**Estimated Count:** ~15-20 identifiers

---

### Category 2: Amendment Relationships

**Pattern:** `(Amendment to IEEE Std X [as amended by Y, Z, ...])`

**Examples:**
```
ANSI PN42.38a/D1 (Amendment to ANSI N42.38-2015)
IEEE Std 802.16m-2011 (Amendment to IEEE Std 802.16-2009)
IEEE 802.1Qch-2017 (Amendment to IEEE Std 802.1Q-2014 as amended by IEEE Std 802.1Qca-2015, ...)
```

**Characteristics:**
- Amendment identifier with explicit base reference
- May list previous amendments that modified the base
- Pattern starts with standalone identifier before parenthetical

**Estimated Count:** ~20-25 identifiers

---

### Category 3: Corrigendum Relationships

**Pattern:** `(Corrigendum to IEEE Std X [as amended by Y, ...])`

**Examples:**
```
IEEE P11073-10418-2011/Cor 1, D4 (Corrigendum to IEEE Std 11073-10418-2011)
Corrigendum to IEEE Std 802.3-2015 as amended by IEEE Std 802.3bw-2015, ...
```

**Characteristics:**
- Corrigendum with explicit base reference
- May reference amendments that modified the base
- Can appear as standalone description (starts with "Corrigendum to...")

**Estimated Count:** ~10-15 identifiers

---

### Category 4: Incorporation Relationships

**Pattern:** `(incorporates IEEE Std X, and IEEE Std Y, ...)`

**Examples:**
```
IEEE Std 1003.1, 2013 Edition (incorporates IEEE Std 1003.1-2008, and IEEE Std 1003.1-2008/Cor 1-2013)
IEEE P802.1AE_Rev/D1.3 (Revision of IEEE Std 802.1AE-2006 Incorporating IEEE Std 802.1AEbn-2011, ...)
```

**Characteristics:**
- Combined/bundled standard incorporating multiple documents
- Typically with "Edition" designation
- Can combine with "Revision of" relationship

**Estimated Count:** ~5-10 identifiers

---

### Category 5: Adoption Relationships

**Pattern:** `(Adoption of X)` or `(ASA X)` or `(ANSI X)`

**Examples:**
```
IEEE Std 1453.1-2012 (Adoption of IEC/TR 61000-3-7:2008)
AIEE Std 42-1923 (ASA C10-1924)
IEEE Std 588-1976 (ANSI C37.86-1975) (Revision of IEEE Std 288-1969 and IEEE Std 328-1971)
```

**Characteristics:**
- IEEE adopts another organization's standard
- Can be combined with revision relationship
- Historical AIEE standards use this pattern

**Estimated Count:** ~5-8 identifiers

---

### Category 6: Supplement Relationships

**Pattern:** `(Supplement to IEEE Std X)`

**Examples:**
```
ANSI/IEEE C37.010e-1985 (Supplement to ANSI/IEEE C37.010-1979)
```

**Characteristics:**
- Supplementary document to base standard
- Less common than amendments/corrigenda
- Similar structure to amendment pattern

**Estimated Count:** ~3-5 identifiers

---

### Category 7: Draft Relationships

**Pattern:** `(Draft Amendment to ...)`, `(Draft Revision of ...)`, `(DRAFT Amendment to ...)`

**Examples:**
```
IEEE Draft P802.3bf/D2.1 (Draft Amendment to IEEE Std 802.3-2008)
IEEE P802.11e/D6.0 (Draft Amendment to IEEE Std 802.11, 1999 Edition (Reaff 2003))
IEEE P802.1AEbn/D0.6 (DRAFT Amendment to IEEE Std 802.1AE-2006)
```

**Characteristics:**
- Draft stage documents with relationship
- Can use "Draft" or "DRAFT" prefix
- May reference reaffirmed bases

**Estimated Count:** ~10-12 identifiers

---

## Complex Pattern Combinations

### Multiple Relationships

**Pattern:** `(Revision of X / Incorporates Y)`

**Example:**
```
IEEE Std C95.1-2019 (Revision of IEEE Std C95.1-2005/ Incorporates IEEE Std C95.1-2019/Cor 1-2019) - Redline
```

**Note:** The `/` separator distinguishes multiple relationship types

---

### Standalone Relationship Starters

**Pattern:** Starts with relationship type instead of identifier

**Examples:**
```
Amendment to IEEE Std 802.11-2007 as amended by IEEE Std 802.11k-2008, ...
Corrigendum to IEEE Std 802.3-2015 as amended by IEEE Std 802.3bw-2015, ...
```

**Note:** These are relationship **descriptions** not full identifiers

---

## Architecture Requirements

### Model Structure Needed

Similar to ISO's `BundledIdentifier`, we need:

1. **Base Class:** `RelationshipIdentifier`
   - Contains base identifier
   - Contains relationship type
   - Contains related identifiers (collection)

2. **Specific Classes** (6-7 types):
   - `RevisionIdentifier` - "Revision of"
   - `AmendmentRelationship` - "Amendment to" (NOTE: different from Amendment supplement)
   - `CorrigendumRelationship` - "Corrigendum to"
   - `IncorporatesIdentifier` - "incorporates"
   - `AdoptionIdentifier` - "Adoption of"
   - `SupplementRelationship` - "Supplement to"
   - `DraftRelationship` - "Draft Amendment/Revision to"

3. **Composite Relationships:**
   - Support multiple relationship types on same identifier
   - Use relationship collection attribute

### Key Design Decisions

1. **Separate from Supplements:** 
   - AmendmentRelationship ≠ Amendment (supplement)
   - CorrigendumRelationship ≠ Corrigendum (supplement)
   - /Amd, /Cor are hierarchical supplements
   - (Amendment to...) are relationship metadata

2. **Recursive Parsing:**
   - Related identifiers must be parsed recursively
   - Example: `(Revision of IEEE Std 802.1AE-2006 Incorporating IEEE Std 802.1AEbn-2011)`
   - Both "802.1AE-2006" and "802.1AEbn-2011" need full parsing

3. **Multiple Targets:**
   - Relationships can have multiple targets
   - Example: `(Revision of IEEE Std 1232-1995, IEEE Std 1232.1-1997, IEEE Std 1232.2-1998)`
   - Need collection of related_identifiers

4. **Standalone Descriptions:**
   - Some identifiers are just relationship descriptions
   - Example: "Amendment to IEEE Std 802.11-2007 as amended by..."
   - May need separate handling or reject these

---

## Parser Strategy

### Detection Pattern

```ruby
rule(:relationship_clause) do
  str("(") >>
  (
    (str("Revision of ") >> relationship_list.as(:revision_of)) |
    (str("Amendment to ") >> relationship_list.as(:amendment_to)) |
    (str("Corrigendum to ") >> relationship_list.as(:corrigendum_to)) |
    (str("incorporates ") >> relationship_list.as(:incorporates)) |
    (str("Incorporating ") >> relationship_list.as(:incorporating)) |
    (str("Adoption of ") >> relationship_list.as(:adoption_of)) |
    (str("Supplement to ") >> relationship_list.as(:supplement_to)) |
    (str("Draft Amendment to ") >> relationship_list.as(:draft_amendment_to)) |
    (str("Draft Revision of ") >> relationship_list.as(:draft_revision_of)) |
    (str("DRAFT Amendment to ") >> relationship_list.as(:draft_amendment_to))
  ) >>
  str(")")
end

rule(:relationship_list) do
  # Parse comma/and-separated list of identifiers
  # Need recursive parsing here
end
```

### Special Cases

1. **"as amended by" clause:**
   ```
   (Amendment to IEEE Std 802.1Q-2014 as amended by IEEE Std 802.1Qca-2015, ...)
                                       ^^^^^^^^^^^^^
   ```
   - Need to parse intermediate amendments
   - These become part of the context, not separate relationships

2. **Multiple relationship delimiters:**
   - Comma: `IEEE Std X, IEEE Std Y, IEEE Std Z`
   - "and": `IEEE Std X and IEEE Std Y`
   - Mixed: `IEEE Std X, IEEE Std Y, and IEEE Std Z`

3. **Combined relationships with slash:**
   ```
   (Revision of IEEE Std C95.1-2005/ Incorporates IEEE Std C95.1-2019/Cor 1-2019)
                                    ^
   ```
   - Slash separates different relationship types
   - Need to support multiple relationships on same identifier

---

## Implementation Phases

### Phase 1: Core Architecture (Session 122)
- Create RelationshipIdentifier base class
- Design 6-7 specific relationship classes
- Define relationship_type constants

### Phase 2: Basic Implementation (Session 123)
- Implement core relationship classes
- Basic to_s rendering
- No parser changes yet

### Phase 3: Parser Enhancement (Session 124)
- Add relationship_clause parsing
- Implement recursive identifier parsing in lists
- Handle "as amended by" clause
- Support multiple relationship types

### Phase 4: Testing & Validation (Session 124-125)
- Create comprehensive specs
- Test recursive parsing
- Test multiple relationships
- Validate against failure samples

---

## Expected Gains

**Total Estimated:** +60-86 identifiers

**By Category:**
- Revision: ~20 IDs
- Amendment relationships: ~25 IDs
- Corrigendum relationships: ~15 IDs
- Incorporates: ~10 IDs
- Adoption: ~8 IDs
- Supplement: ~5 IDs
- Draft relationships: ~12 IDs

**Note:** Some overlap possible, actual gain may vary

---

## Architecture Validation

Follows MODEL-DRIVEN principles:
- ✅ Objects not strings
- ✅ Composition (identifiers contain identifiers)
- ✅ MECE (each relationship type distinct)
- ✅ Similar to ISO BundledIdentifier pattern
- ✅ Clean separation (parser/builder/identifier)

---

**Next Step:** Design model classes (60 min)