# pdfstamp

Stamps each PDF file with its own filename as a watermark, in-place.

## Usage

```bash
pdfstamp .                        # stamp all *.pdf / *.PDF in current directory
pdfstamp -a                       # same
pdfstamp report.pdf notes.pdf     # stamp specific files
pdfstamp -f .                     # stamp first page only
pdfstamp -n .                     # dry-run: show what would happen, modify nothing
pdfstamp -q .                     # quiet: no output unless there's an error
pdfstamp -- -oddly-named.pdf      # use -- to pass filenames starting with -
```

## Options

| Flag | Long form | Description |
|------|-----------|-------------|
| `.` or `-a` | `--all` | Process all `*.pdf` / `*.PDF` in current directory |
| `-f` | `--first` | Stamp first page only (default: all pages) |
| `-n` | `--dry-run` | Show what would be stamped without modifying files |
| `-q` | `--quiet` | Suppress all non-error output |
| | `--version` | Print version and backend version, then exit |
| `-h` | `--help` | Print help and exit |
| `--` | | End of options; treat remaining args as filenames |

## Installation

```bash
git clone https://github.com/marekkowalczyk/pdfstamp.git
ln -s "$PWD/pdfstamp/pdfstamp" /usr/local/bin/pdfstamp
```

Or install the full [pdftools](https://github.com/marekkowalczyk/pdftools) suite.

## Requirements

- [cpdf](https://www.coherentpdf.com/) (Coherent PDF command-line tools)
- bash

## How it works

For each PDF file:

1. Runs `cpdf` to add the filename as text at the bottom of each page
2. Writes output to a temp file (via `mktemp`) in the same directory as the source
3. Copies file permissions and extended attributes (Finder tags, Spotlight comments) to the temp file
4. Replaces the original with the stamped version
5. Cleans up the temp file on exit, even if interrupted

## Development

Install the pre-commit hook (runs the test suite before every commit):

```bash
bash hooks/install.sh
```

Run tests manually:

```bash
bats tests/pdfstamp.bats
```

35 tests using a mock `cpdf` binary — no real PDFs required.

## License

MIT
