# ITU PubID v2 - MODEL-DRIVEN Architecture

## Overview

ITU (International Telecommunication Union) with 3 sectors (R/T/D), multiple series, and complex supplement system.

**Target**: 2,041+ test cases (ITU-R alone)

## Architecture Summary

### Main Identifier Types (5)

1. **Recommendation** - Base type (ITU-R V.1234-1)
2. **Resolution** - R series (ITU-R R.1)
3. **Question** - Study groups (ITU-R SG1.234)
4. **RegulatoryPublication** - RR, ROP, HFBS
5. **SpecialPublication** - OB (Operational Bulletin)

### Supplement Types (6)

1. Amendment (Amd 1)
2. Supplement (Suppl. 1)
3. Annex (Annex A)
4. Corrigendum (Cor. 1)
5. Addendum (Add. 1)
6. Appendix (App. I)

### Format Patterns

```
ITU-{SECTOR} {SERIES}.{NUMBER}[-PART]
ITU-R V.1234-1
ITU-T X.25
ITU-D 789

With supplements:
ITU-R BO.650-2 Amd 1
ITU-T H.264 Suppl. 5
ITU-R V.234 Annex A
```

### Components

- Sector (R/T/D)
- Series (from series.yaml)
- Code (number + subseries + parts)
- Date (multiple formats, Roman numerals)

Implementation continuing...