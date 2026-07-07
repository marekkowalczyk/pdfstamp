# After Action Review

Continuous improvement log. Each session ends with a brief review: what went well, what didn't, what to change. This is the POOGI (Process Of Ongoing Improvement) record for this project.

## 2026-07-08 — Convention compliance, batch mode, and bats test suite

**What went well:**
- Convention compliance was systematic — reading `CONVENTIONS.md` first gave a clear checklist, nothing was missed
- The bats mock pattern (small shell scripts injected into `$PATH`) is clean and portable; all 35 tests passed first run with no fixes needed
- Checking `pdfclean` as a reference before implementing was the right call — it provided the exact patterns to follow for batch mode, error messages, temp file handling, and test structure

**What didn't go well:**
- The initial `.` implementation didn't include `--all`/`-a` — required a second pass immediately after; reading the full `CONVENTIONS.md` before writing any code would have caught this
- `-v`/`--verbose` was present from the original script and wasn't caught as non-standard until the convention audit; it should have been flagged in the initial `.` implementation

**What we'll do differently:**
- Before implementing any feature, read `CONVENTIONS.md` in full first — not after the fact
- When adding a feature that touches CLI flags, cross-check the full standard flags table immediately
