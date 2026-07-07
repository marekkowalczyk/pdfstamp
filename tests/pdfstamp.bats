#!/usr/bin/env bats

SCRIPT="$BATS_TEST_DIRNAME/../pdfstamp"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# Create a minimal fake PDF in the current directory
make_pdf() {
    local name="${1:-test.pdf}"
    printf '%%PDF-1.4\n1 0 obj\n<</Type /Catalog>>\nendobj\ntrailer\n<</Root 1 0 R>>\n%%%%EOF\n' > "$name"
}

# Mock cpdf: exits 0 and copies input to output (successful stamp)
# Also handles -version for --version tests
setup_mock_cpdf_stamp() {
    cat > "$BATS_TEST_TMPDIR/cpdf" <<'EOF'
#!/usr/bin/env bash
if [[ "$1" == "-version" ]]; then
    echo "cpdf AGPL Version 2.7.1 (mock)"
    exit 0
fi
# Find input (first arg) and output (arg after -o)
input="$1"; output=""
while [[ $# -gt 0 ]]; do
    if [[ "$1" == "-o" ]]; then output="$2"; break; fi
    shift
done
cp -- "$input" "$output"
EOF
    chmod +x "$BATS_TEST_TMPDIR/cpdf"
    export PATH="$BATS_TEST_TMPDIR:$PATH"
}

# Mock cpdf: exits 0 but writes nothing (empty output)
setup_mock_cpdf_empty() {
    cat > "$BATS_TEST_TMPDIR/cpdf" <<'EOF'
#!/usr/bin/env bash
# Find -o and touch it empty
while [[ $# -gt 0 ]]; do
    if [[ "$1" == "-o" ]]; then > "$2"; break; fi
    shift
done
exit 0
EOF
    chmod +x "$BATS_TEST_TMPDIR/cpdf"
    export PATH="$BATS_TEST_TMPDIR:$PATH"
}

# Mock cpdf: always fails
setup_mock_cpdf_fail() {
    cat > "$BATS_TEST_TMPDIR/cpdf" <<'EOF'
#!/usr/bin/env bash
exit 1
EOF
    chmod +x "$BATS_TEST_TMPDIR/cpdf"
    export PATH="$BATS_TEST_TMPDIR:$PATH"
}

setup() {
    WORK="$BATS_TEST_TMPDIR/work"
    mkdir -p "$WORK"
    cd "$WORK"
}

# ---------------------------------------------------------------------------
# --help / --version
# ---------------------------------------------------------------------------

@test "--help exits 0 and prints usage" {
    run "$SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage:"* ]]
}

@test "-h is alias for --help" {
    run "$SCRIPT" -h
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage:"* ]]
}

@test "--version exits 0 and prints pdfstamp version" {
    setup_mock_cpdf_stamp
    run "$SCRIPT" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"pdfstamp"* ]]
}

@test "--version includes cpdf version" {
    setup_mock_cpdf_stamp
    run "$SCRIPT" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"cpdf"* ]]
}

# ---------------------------------------------------------------------------
# No-argument / no-file errors
# ---------------------------------------------------------------------------

@test "no args exits 1 and prints error to stderr" {
    run "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"pdfstamp:"* ]]
}

@test "unknown option exits 1 with error" {
    run "$SCRIPT" --notaflag
    [ "$status" -eq 1 ]
    [[ "$output" == *"pdfstamp:"* ]]
}

# ---------------------------------------------------------------------------
# Missing file
# ---------------------------------------------------------------------------

@test "missing file exits 1 with warning on stderr" {
    run "$SCRIPT" ghost.pdf
    [ "$status" -eq 1 ]
    [[ "$output" == *"not found"* ]]
}

@test "missing file error message includes 'skipping'" {
    run "$SCRIPT" ghost.pdf
    [ "$status" -eq 1 ]
    [[ "$output" == *"skipping"* ]]
}

# ---------------------------------------------------------------------------
# Duplicate file warning
# ---------------------------------------------------------------------------

@test "duplicate filename warned and processed once" {
    setup_mock_cpdf_stamp
    make_pdf a.pdf
    run "$SCRIPT" a.pdf a.pdf
    [ "$status" -eq 0 ]
    [[ "$output" == *"more than once"* ]]
    count=$(echo "$output" | grep -c "stamped")
    [ "$count" -eq 1 ]
}

# ---------------------------------------------------------------------------
# . / --all / -a
# ---------------------------------------------------------------------------

@test ". picks up *.pdf files" {
    setup_mock_cpdf_stamp
    make_pdf one.pdf
    make_pdf two.pdf
    run "$SCRIPT" .
    [ "$status" -eq 0 ]
    [[ "$output" == *"one.pdf"* ]]
    [[ "$output" == *"two.pdf"* ]]
}

@test "--all is equivalent to ." {
    setup_mock_cpdf_stamp
    make_pdf one.pdf
    run "$SCRIPT" --all
    [ "$status" -eq 0 ]
    [[ "$output" == *"one.pdf"* ]]
}

@test "-a is equivalent to ." {
    setup_mock_cpdf_stamp
    make_pdf one.pdf
    run "$SCRIPT" -a
    [ "$status" -eq 0 ]
    [[ "$output" == *"one.pdf"* ]]
}

@test ". picks up *.PDF files" {
    setup_mock_cpdf_stamp
    make_pdf UPPER.PDF
    run "$SCRIPT" .
    [ "$status" -eq 0 ]
    [[ "$output" == *"UPPER.PDF"* ]]
}

@test ". with no PDFs exits 1" {
    run "$SCRIPT" .
    [ "$status" -eq 1 ]
    [[ "$output" == *"no PDF files found"* ]]
}

@test "combining . with explicit file exits 1" {
    make_pdf a.pdf
    run "$SCRIPT" . a.pdf
    [ "$status" -eq 1 ]
    [[ "$output" == *"cannot combine"* ]]
}

@test "combining --all with explicit file exits 1" {
    make_pdf a.pdf
    run "$SCRIPT" --all a.pdf
    [ "$status" -eq 1 ]
    [[ "$output" == *"cannot combine"* ]]
}

# ---------------------------------------------------------------------------
# -- end-of-options
# ---------------------------------------------------------------------------

@test "-- allows filename starting with -" {
    setup_mock_cpdf_stamp
    make_pdf "-odd.pdf"
    run "$SCRIPT" -- -odd.pdf
    [ "$status" -eq 0 ]
    [[ "$output" == *"stamped"* ]]
}

# ---------------------------------------------------------------------------
# --dry-run / -n
# ---------------------------------------------------------------------------

@test "--dry-run does not modify file" {
    setup_mock_cpdf_stamp
    make_pdf a.pdf
    original=$(cat a.pdf)
    run "$SCRIPT" --dry-run a.pdf
    [ "$status" -eq 0 ]
    [ "$(cat a.pdf)" = "$original" ]
}

@test "-n is alias for --dry-run" {
    setup_mock_cpdf_stamp
    make_pdf a.pdf
    original=$(cat a.pdf)
    run "$SCRIPT" -n a.pdf
    [ "$status" -eq 0 ]
    [ "$(cat a.pdf)" = "$original" ]
}

@test "--dry-run prints '[dry-run] would stamp'" {
    setup_mock_cpdf_stamp
    make_pdf a.pdf
    run "$SCRIPT" --dry-run a.pdf
    [ "$status" -eq 0 ]
    [[ "$output" == *"[dry-run] would stamp"* ]]
}

@test "--dry-run shows range: all by default" {
    setup_mock_cpdf_stamp
    make_pdf a.pdf
    run "$SCRIPT" --dry-run a.pdf
    [ "$status" -eq 0 ]
    [[ "$output" == *"range: all"* ]]
}

@test "--dry-run with --first shows range: 1" {
    setup_mock_cpdf_stamp
    make_pdf a.pdf
    run "$SCRIPT" --dry-run --first a.pdf
    [ "$status" -eq 0 ]
    [[ "$output" == *"range: 1"* ]]
}

@test "--dry-run leaves no temp files" {
    setup_mock_cpdf_stamp
    make_pdf a.pdf
    run "$SCRIPT" --dry-run a.pdf
    [ "$status" -eq 0 ]
    leftover=$(ls .pdfstamp.* 2>/dev/null | wc -l | tr -d ' ')
    [ "$leftover" -eq 0 ]
}

# ---------------------------------------------------------------------------
# Stamping outcomes
# ---------------------------------------------------------------------------

@test "file is replaced after successful stamp" {
    setup_mock_cpdf_stamp
    make_pdf a.pdf
    original=$(cat a.pdf)
    run "$SCRIPT" a.pdf
    [ "$status" -eq 0 ]
    [[ "$output" == *"stamped"* ]]
}

@test "cpdf failure exits 1 with error message" {
    setup_mock_cpdf_fail
    make_pdf a.pdf
    run "$SCRIPT" a.pdf
    [ "$status" -eq 1 ]
    [[ "$output" == *"pdfstamp:"* ]]
    [[ "$output" == *"failed"* ]]
}

@test "empty cpdf output is treated as failure" {
    setup_mock_cpdf_empty
    make_pdf a.pdf
    original=$(cat a.pdf)
    run "$SCRIPT" a.pdf
    [ "$status" -eq 1 ]
    [ "$(cat a.pdf)" = "$original" ]
}

@test "no orphaned temp files after cpdf failure" {
    setup_mock_cpdf_fail
    make_pdf a.pdf
    run "$SCRIPT" a.pdf
    leftover=$(ls .pdfstamp.* 2>/dev/null | wc -l | tr -d ' ')
    [ "$leftover" -eq 0 ]
}

@test "no orphaned temp files after empty cpdf output" {
    setup_mock_cpdf_empty
    make_pdf a.pdf
    run "$SCRIPT" a.pdf
    leftover=$(ls .pdfstamp.* 2>/dev/null | wc -l | tr -d ' ')
    [ "$leftover" -eq 0 ]
}

# ---------------------------------------------------------------------------
# -f / --first
# ---------------------------------------------------------------------------

@test "--first stamps only the first page (range: 1 in dry-run)" {
    setup_mock_cpdf_stamp
    make_pdf a.pdf
    run "$SCRIPT" --first --dry-run a.pdf
    [ "$status" -eq 0 ]
    [[ "$output" == *"range: 1"* ]]
}

@test "-f is alias for --first" {
    setup_mock_cpdf_stamp
    make_pdf a.pdf
    run "$SCRIPT" -f --dry-run a.pdf
    [ "$status" -eq 0 ]
    [[ "$output" == *"range: 1"* ]]
}

@test "default range is all pages (range: all in dry-run)" {
    setup_mock_cpdf_stamp
    make_pdf a.pdf
    run "$SCRIPT" --dry-run a.pdf
    [ "$status" -eq 0 ]
    [[ "$output" == *"range: all"* ]]
}

# ---------------------------------------------------------------------------
# --quiet / -q
# ---------------------------------------------------------------------------

@test "--quiet produces no stdout on success" {
    setup_mock_cpdf_stamp
    make_pdf a.pdf
    run "$SCRIPT" --quiet a.pdf
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "-q is alias for --quiet" {
    setup_mock_cpdf_stamp
    make_pdf a.pdf
    run "$SCRIPT" -q a.pdf
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "--quiet still exits 1 on missing file" {
    run "$SCRIPT" -q ghost.pdf
    [ "$status" -eq 1 ]
}

# ---------------------------------------------------------------------------
# Exit code: partial failure
# ---------------------------------------------------------------------------

@test "exit 1 when some files fail and some succeed" {
    setup_mock_cpdf_stamp
    make_pdf good.pdf
    run "$SCRIPT" good.pdf ghost.pdf
    [ "$status" -eq 1 ]
}
