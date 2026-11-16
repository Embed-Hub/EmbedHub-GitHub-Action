#!/bin/bash
# Tests entrypoint.sh with a stub `embedhub` on PATH: no network, no Docker.
#   test/entrypoint_test.sh            (also: test/image_test.sh builds the image)
set -uo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
FAILED=0
pass() { printf '  PASS  %s\n' "$*"; }
fail() { printf '  FAIL  %s\n' "$*"; FAILED=1; }

# The stub records how it was called, and fails on purpose for a "bad" project.
mkdir -p "$WORK/bin"
cat > "$WORK/bin/embedhub" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >> "$CALLS"
printf 'token=%s\n' "${EMBEDHUB_TOKEN:-}" >> "$CALLS"
for a in "$@"; do case "$a" in */bad-project) echo "denied" >&2; exit 1 ;; esac; done
exit 0
STUB
chmod +x "$WORK/bin/embedhub"

run() { # env... -- args...: runs the entrypoint in $WORK/src; sets OUT, CODE
    : > "$WORK/calls"; : > "$WORK/gh_output"
    OUT="$(cd "$WORK/src" && env PATH="$WORK/bin:$PATH" CALLS="$WORK/calls" GITHUB_OUTPUT="$WORK/gh_output" "$@" bash "$HERE/entrypoint.sh" "${ARGS[@]}" 2>&1)"
    CODE=$?
}
mkdir -p "$WORK/src/build" && printf 'a' > "$WORK/src/build/a.bin" && printf 'b' > "$WORK/src/build/b.bin"
TOKEN="ehp_pt-1234_s3cret"

echo "=== happy path"
ARGS=(acme firmware 'build/*.bin' releases/v1/ .)
run EMBEDHUB_TOKEN="$TOKEN"
[ $CODE -eq 0 ] && pass "exit 0" || fail "exit $CODE: $OUT"
grep -qx "push build/a.bin build/b.bin acme/firmware --path releases/v1/" "$WORK/calls" && pass "push gets the expanded files, project and path" || fail "calls: $(cat "$WORK/calls")"
grep -qx "token=$TOKEN" "$WORK/calls" && pass "the token reaches the CLI in the environment" || fail "token not in env"
grep -q "s3cret" <(head -1 "$WORK/calls") && fail "the token appeared as an argument" || pass "the token is not an argument"
grep -qx "uploaded=true" "$WORK/gh_output" && grep -qx "file_count=2" "$WORK/gh_output" && pass "outputs: uploaded=true, file_count=2" || fail "outputs: $(cat "$WORK/gh_output")"
grep -q "s3cret" <<<"$OUT" && fail "the token was printed" || pass "the token is not printed"

echo "=== default path (no path input)"
ARGS=(acme firmware 'build/a.bin' '' .)
run EMBEDHUB_TOKEN="$TOKEN"
grep -qx "push build/a.bin acme/firmware" "$WORK/calls" && pass "no --path when path is empty" || fail "calls: $(cat "$WORK/calls")"

echo "=== working-directory"
mkdir -p "$WORK/src/sub/out" && printf 'c' > "$WORK/src/sub/out/c.bin"
ARGS=(acme firmware 'out/*.bin' releases/ sub)
run EMBEDHUB_TOKEN="$TOKEN"
grep -qx "push out/c.bin acme/firmware --path releases/" "$WORK/calls" && pass "globs resolve inside working-directory" || fail "calls: $(cat "$WORK/calls")"

echo "=== refusals"
ARGS=(acme firmware 'build/*.bin' releases/ .)
run EMBEDHUB_TOKEN=""
[ $CODE -ne 0 ] && grep -q "project token is required" <<<"$OUT" && [ ! -s "$WORK/calls" ] && pass "no token: exits non-zero, says so, runs nothing" || fail "no token: $CODE $OUT"
run EMBEDHUB_TOKEN="ehk_0123456789abcdef_oldkey"
[ $CODE -ne 0 ] && grep -q "starts with ehp_" <<<"$OUT" && [ ! -s "$WORK/calls" ] && pass "an old API key is refused before running anything" || fail "old key: $CODE $OUT"
ARGS=(acme firmware 'nothing/*.bin' releases/ .)
run EMBEDHUB_TOKEN="$TOKEN"
[ $CODE -ne 0 ] && grep -q "No files found" <<<"$OUT" && pass "no matching files: exits non-zero" || fail "no files: $CODE $OUT"
ARGS=(acme bad-project 'build/a.bin' releases/ .)
run EMBEDHUB_TOKEN="$TOKEN"
[ $CODE -ne 0 ] && grep -qx "uploaded=false" "$WORK/gh_output" && pass "a failed upload fails the step, uploaded=false" || fail "failed upload: $CODE $(cat "$WORK/gh_output")"
for missing in 0 1 2; do
    ARGS=(acme firmware 'build/a.bin' releases/ .); ARGS[$missing]=""
    run EMBEDHUB_TOKEN="$TOKEN"
    [ $CODE -ne 0 ] && [ ! -s "$WORK/calls" ] && pass "missing input #$((missing+1)) refused" || fail "missing input #$((missing+1)): $CODE"
done

echo "=== action.yml"
grep -q "EMBEDHUB_TOKEN: \${{ inputs.token }}" "$HERE/action.yml" && pass "token passed as env" || fail "action.yml env"
grep -q "inputs.token" <(sed -n '/args:/,$p' "$HERE/action.yml") && fail "token passed as an arg" || pass "token not in args"
grep -q "api-key" "$HERE/action.yml" && fail "api-key input still there" || pass "no api-key input"

[ $FAILED -eq 0 ] && echo "ALL PASS" || echo "FAILURES ABOVE"
exit $FAILED
