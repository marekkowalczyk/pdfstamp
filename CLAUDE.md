# pdfstamp

PDF filename watermarking tool. Uses `cpdf` as its backend.

## Start/End

Every session begins with `/start` and ends with `/close`.

## What it does

- Accepts one or more PDF files as arguments; `.` / `--all` / `-a` processes all `*.pdf` / `*.PDF` in the current directory
- Errors if called with no arguments
- Stamps each file in-place: adds the filename as text at the bottom of each page (or first page only with `-f`)
- Warns and skips duplicate filenames

## Structure

Single bash script: `pdfstamp`. Symlinked from `/usr/local/bin/pdfstamp`.

Tests: `tests/pdfstamp.bats` (35 tests, mock `cpdf` backend — no real PDFs required).

Pre-commit hook: `hooks/pre-commit`. Install with `bash hooks/install.sh`.

## Dependencies

- `cpdf` (Coherent PDF command-line tools, must be installed separately)
- `stat` (macOS `stat -f%Mp%Lp` for permissions)
- `xattr` (for preserving extended attributes)

## Design decisions

- Files are stamped to a `mktemp` file in the same directory as the source (same filesystem → atomic `mv`). Temp file is cleaned up via `trap` on exit/interrupt.
- Before the swap, file permissions and extended attributes (Finder tags, Spotlight comments) are copied from the original to the temp file.
- Output from `cpdf` must be non-empty (`-s` check) before the swap is accepted.
- No recursive directory walking by design. User controls which files are processed.
- All errors and warnings go to stderr; exit code reflects any failures.
- Output is minimal by Unix convention: report each file stamped, silent on errors only with `-q`. Errors prefixed with `pdfstamp:`.

## Suite

`pdfstamp` is part of the [pdftools](https://github.com/marekkowalczyk/pdftools) suite. Cross-tool CLI and Unix citizenship conventions are documented in [pdftools/CONVENTIONS.md](https://github.com/marekkowalczyk/pdftools/blob/master/CONVENTIONS.md). Design decisions here should stay consistent with those conventions. **Read `CONVENTIONS.md` in full before touching any CLI flags or adding features.**

## Key documents

- **NEXT-SESSION.md** — open questions and items for the next session.
- **AAR.md** — after action reviews, continuous improvement log.
