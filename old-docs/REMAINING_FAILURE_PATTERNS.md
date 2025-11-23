# Remaining Failure Patterns Analysis

## IEEE Failures Summary (3,582 failures out of 10,332 tested)

### Top Failure Categories:

1. **Draft Patterns: 416 failures**
   - Issue: Complex draft patterns with project numbers and dates
   - Examples: `IEEE Unapproved Draft Std P11073-10404/D09, Sept 2008`
   - Pattern: `P####/D##, Month Year` or `P####/D## Month Year`

2. **Other Patterns: 2,000+ failures**
   - Complex identifier patterns not yet categorized
   - Need detailed sub-categorization

3. **Remaining categories need analysis:**
   - Dual Published (and)
   - Adopted Standard (parenthetical)
   - IEC/IEEE Copublished
   - Standard Numbers
   - Version.Iteration
   - Redlined Standard
   - Project Numbers
   - Corrigendum
   - Amendment

## NIST Failures Summary (1,349 failures out of 20,350 tested)

### Top Failure Categories:

1. **Other Patterns: 1,326 failures**
   - Complex NBS/NIST patterns
   - Examples: `NBS CIRC 24suppJan1924`, `NBS CIRC 25insert`
   - Pattern: Mixed supplement, date, and insertion patterns

2. **Project Numbers: 12 failures**
   - Issue: Complex project/supplement patterns
   - Examples: `NBS LCIRC 118supp3/1926`, `NBS TN 467p1adde1`

3. **Machine-readable versions: 6 failures**
   - Issue: Dot-separated version patterns
   - Examples: `NIST.SP.984.4` (part 4), `NIST.SP.500-281-v1.0` (version 1.0)

4. **Draft Patterns: 5 failures**
   - Issue: Draft suffix patterns
   - Examples: `NIST IR 8286C-draft`, `NIST SP 800-219-draft`

## Key Patterns to Implement

### IEEE Priority Patterns:

`gems/pubid-ieee/update_codes.yaml` contains codes that we manually map because
there is no need to manually parse them.

1. **Drafts with Date Patterns**: `P####/D##, Month Year`
2. **Drafts with Project Numbers with Parts**: `P####-#####/D##`
3. **Drafts with Version.Iteration**: `P####/D#.#`
4. **Unapproved Draft Std patterns**: Full parsing support

### NIST Priority Patterns:

`gems/pubid-nist/update_codes.yaml` contains codes that we manually map because
there is no need to manually parse them.

1. **Supplement Patterns**: `suppJan1924`, `supp3/1926`, `supp1925`
2. **Sub-Component Patterns**: `insert` (an insert inside a document), `p1adde1` (part 1 addition edition 1)
3. **Date Range Patterns**: `Jul-Sep1949`, `Jul-Sep1950`
4. **Dot-separated Versions**: `NIST.SP.###.#`, `NIST.SP.###-###-v#.#`
5. **Draft Suffix**: `-draft` patterns
6. **Hash-prefixed**: `#NIST.####-##-##.###` patterns

## Next Steps for Implementation

1. **IEEE**: Focus on complex draft patterns with project numbers and dates
2. **NIST**: Implement supplement, insertion, and date range patterns
3. **Both**: Handle version.iteration and draft suffix patterns
4. **Testing**: Validate against the specific failure examples provided

The analysis shows we need to implement more sophisticated pattern matching for complex identifier structures, particularly around draft status, supplements, and version numbering schemes.