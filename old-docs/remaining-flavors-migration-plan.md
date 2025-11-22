# Remaining Flavors Migration Plan

## Completed Flavors ✅

1. **ISO** - 99.52% (7,080/7,114 tests)
2. **IEC** - 100% (all tests passing)
3. **IDF** - 100% (existing implementation)
4. **CEN** - 100% (50 tests passing)

## Remaining Flavors (by complexity)

### 1. CCSDS (9 files) - SIMPLEST

**Format:** `CCSDS 1234.1-B-2` (Cor. 1 for corrigenda)

**Unique Features:**
- Uses dots (`.`) for parts, not dashes
- Book color codes: B, G, M, Y, O, R (single letter)
- Format: `CCSDS {series?}{number}.{part}-{color}-{edition}`
- Optional retired marker: `-S`
- Language translations noted

**Example IDs:**
- `CCSDS 1234.1-B-2`
- `CCSDS A123.1-B-1`
- `CCSDS 1234.1-B-2 Cor. 1`

**Migration Strategy:**
- Create `CcsdsIdentifier < SingleIdentifier`
- Custom `to_s` for dot-separated parts
- Add `:book_color` attribute
- Simple parser (no complex operators)

### 2. IEEE (10 files)

**Format:** `IEEE 802.11-2020`

**Features:**
- Similar to ISO but simpler
- Uses dots for parts
- Year-based dating
- No complex supplements

**Migration:** Similar to CCSDS, dot-notation parts

### 3. ETSI (12 files)

**Format:** `ETSI TS 102 822-1 V1.1.1 (2003-10)`

**Unique Features:**
- Version numbers with dots: `V1.1.1`
- Month-based dates in parentheses
- Multiple document types (TS, TR, EN, ES, EG, SR, GS, GR)

**Migration:** Need version component, special date format

### 4. PLATEAU (12 files)

**Format:** To be analyzed

**Migration:** TBD based on analysis

### 5. JIS (17 files)

**Format:** `JIS X 0208:1997`

**Features:**
- Series letter + number format
- Similar to ISO structure
- May support amendments

**Migration:** Should be similar to ISO pattern

### 6. ITU (25 files) - MODERATE

**Format:** `ITU-T G.711` or `ITU-R BT.601-7`

**Features:**
- Two divisions: ITU-T (telecom), ITU-R (radio)
- Series + number with dots
- Amendments supported
- Complex series system

**Migration:** Medium complexity, need series

 handling

### 7. BSI (29 files) - COMPLEX

**Format:** `BS EN ISO 9001:2015` (adopted standards)

**Features:**
- British Standards
- Adopts ISO/IEC/EN standards
- Complex adoption chains
- Many document types
- Amendments and corrigenda

**Migration:** Complex - needs adoption pattern

### 8. NIST (34 files) - MOST COMPLEX

**Format:** `NIST SP 800-53 Rev. 5`

**Features:**
- Multiple series (SP, FIPS, etc.)
- Revision system
- Volume, Part 1, Part 2 structure
- Complex metadata
- Many publisher types

**Migration:** Most complex - needs careful design

## Recommended Migration Order

1. **CCSDS** (1-2 hours) - Simple, establish dot-notation pattern
2. **IEEE** (1-2 hours) - Similar to CCSDS
3. **JIS** (2-3 hours) - Similar to ISO
4. **ETSI** (2-3 hours) - Version numbers
5. **PLATEAU** (2-3 hours) - TBD after analysis
6. **ITU** (3-4 hours) - Moderate complexity
7. **BSI** (4-5 hours) - Adoption chains
8. **NIST** (5-6 hours) - Most complex

**Total Estimated Time:** 20-30 hours

## Migration Checklist (per flavor)

- [ ] Analyze old structure (`gems/pubid-{flavor}/`)
- [ ] Create identifier classes
- [ ] Create scheme
- [ ] Create parser
- [ ] Create builder
- [ ] Test manually with examples
- [ ] Port existing tests
- [ ] Run full test suite
- [ ] Document unique features

## Next Session Starting Point

**Immediate Next Task:** Migrate CCSDS

**Test Examples Needed:**
```ruby
'CCSDS 123.1-B-1'
'CCSDS A123.1-G-2'
'CCSDS 123.1-B-1-S'  # retired
'CCSDS 123.1-B-1 Cor. 1'
```

**Pattern to Follow:** CEN migration (just completed)

**Key Differences from ISO/CEN:**
- Dots for parts (not dashes)
- Book color attribute
- Simpler structure (no stages, fewer types)

---

*Ready for systematic migration of remaining 8 flavors*