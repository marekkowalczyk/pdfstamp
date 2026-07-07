# Next Session

## Completed last session ✓

- [x] ~~`pdfstamp .` / `--all` / `-a` batch mode~~
- [x] ~~Full pdftools convention compliance: `--version`, `--quiet`/`-q`, error prefixes, duplicate detection, `-` filename handling, `trap` cleanup, `chmod`+`xattr` copy~~
- [x] ~~Bats test suite (35 tests, all passing)~~
- [x] ~~Pre-commit hook (`hooks/pre-commit` + `hooks/install.sh`)~~
- [x] ~~README.md~~
- [x] ~~CLAUDE.md~~
- [x] ~~`pdftools/CONVENTIONS.md` — added Repo structure section~~
- [x] ~~AAR.md~~

## Open questions

- **Tool name:** Is `pdfstamp` the right name? Consider whether the name is
  clear enough about what it does (adds the filename as a visible watermark)
  vs. other meanings of "stamp" (rubber stamp, date stamp, Bates stamp).

- **Scope:** Consider folding in related tools:
  - `pdfbates` — Bates numbering is a similar in-place text-overlay operation;
    could be a `--bates` mode or a separate tool that shares conventions
  - `pdfrem` — unclear overlap yet; revisit once scope of pdfrem is clearer

## Start-of-session checklist

Run `bats tests/pdfstamp.bats` first — before writing any new code — to catch
pre-existing failures early.

Read `CONVENTIONS.md` in full before touching any CLI flags or adding features.
