#!/usr/bin/env python3
"""Generate pubid_urn_schema.rb files for a batch of flavors from docs/URN-SCHEMES.adoc.

The doc is the design authority (token, core, atom order, facets). The generated
schema declares exactly what the doc's section states; the contract gate then
verifies against the whole fixture corpus.
"""
import re
import sys

DOC = "docs/URN-SCHEMES.adoc"
OUT = "lib/pubid/{flavor}/pubid_urn_schema.rb"
MODULE_FILE = "lib/pubid/{flavor}.rb"

s = open(DOC).read()

def section(flavor):
    m = re.search(rf"==== {flavor}\n(.*?)(?=\n\[\[urn-|\n==== |\Z)", s, re.S)
    return m.group(1) if m else None

def parse_atoms(body):
    """'`series-` (`series`), `year-` (`year`)' -> [(path, prefix, kind)]"""
    out = []
    m = re.search(r"Atoms, canonical order: (.*?)(?:\n\n|\nFacet|\nNested|\Z)", body, re.S)
    if not m:
        return out
    for item in re.finditer(r"`([a-z0-9.*]+)-`\s*\((`[^`]+`|\.\.\.)\)(?:\s*,\s*([^,)\n]+))?", m.group(1)):
        pass  # structure varies; fall back to pair regex below
    for pair in re.finditer(r"`([a-z0-9.*]+)-`\s*\(`([^`]+)`\)(\s*,\s*(bool|int))?", m.group(1)):
        prefix, path, _dot, kind = pair.groups()
        out.append((path, prefix, (kind or "").strip()))
    return out

def parse_facets(body):
    out = []
    m = re.search(r"Facet[^\n]*?(?:candidates|, canonical order)?[^:]*: (.*?)(?:\n\n|\nNested|\Z)", body, re.S)
    if not m:
        return out
    for pair in re.finditer(r"`([a-z0-9.*]+)-`\s*\(`([^`]+)`\)(\s*,\s*(bool))?", m.group(1)):
        prefix, path, _dot, kind = pair.groups()
        out.append((path, prefix, (kind or "").strip()))
    return out

def parse_types(body):
    """table rows: | `pubid:x:y` | `token` | core | ids | example"""
    out = []
    for row in re.finditer(r"\| `(pubid:[^`]+)` \| `([^`]+)` \| ([^|]+) \|", body):
        type_, token, core = row.group(1), row.group(2), row.group(3).strip()
        out.append((type_, token, core))
    return out

def ruby_kind(kind):
    return ", kind: :bool" if kind == "bool" else (", kind: :int" if kind == "int" else "")

def gen(flavor):
    body = section(flavor)
    if not body:
        print(f"SKIP {flavor}: no doc section")
        return False
    atoms = parse_atoms(body)
    facets = parse_facets(body)
    types = parse_types(body)
    if not types:
        print(f"SKIP {flavor}: no type table rows parsed")
        return False

    lines = []
    for path, prefix, kind in atoms:
        lines.append(f'      atom "{path}", "{prefix}"{ruby_kind(kind)}')
    if facets or atoms:
        pass
    lines.append("")
    for path, prefix, kind in facets:
        lines.append(f'      facet "{path}", "{prefix}"{ruby_kind(kind)}')
    lines.append("")
    for type_, token, core in types:
        core_arg = ""
        if core in ("—", "-"):
            core_arg = ", core: []"
        elif core.strip() != "number":
            paths = " ".join(core.split())
            parts = re.split(r"[ ,/+]| and ", paths)
            core_arg = ", core: " + repr([x for x in parts if x])
        lines.append(f'      type "{type_}", "{token}"{core_arg}')

    body_ruby = "\n".join(lines).strip("\n")
    module_snake = flavor.replace("_", " ").title().replace(" ", "")
    content = f'''# frozen_string_literal: true

module Pubid
  module {module_snake}
    # The pubid-scheme URN of {flavor} (issue #656; docs/URN-SCHEMES.adoc).
    #
    # Declared from the doc's section: the atom, facet and type tables
    # below are the doc's design, conforming token-for-token.
    PubidUrnSchema = Pubid::PubidUrn.define("{flavor}") do
      {body_ruby}
    end
  end
end
'''
    import os
    os.makedirs(f"lib/pubid/{flavor}", exist_ok=True)
    open(OUT.format(flavor=flavor), "w").write(content)
    print(f"WROTE {flavor}: {len(atoms)} atoms, {len(facets)} facets, {len(types)} types")
    return True

for flavor in sys.argv[1:]:
    gen(flavor)
