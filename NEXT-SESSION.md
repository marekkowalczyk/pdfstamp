# Next Session

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
