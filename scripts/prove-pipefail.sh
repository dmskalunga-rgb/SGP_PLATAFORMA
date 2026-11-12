#!/usr/bin/env bash
set -euo pipefail
mkdir -p artifacts
fixture=$(mktemp artifacts/pipefail-test-XXXXXX.mjs)
trap 'rm -f "$fixture"' EXIT
set +e
bash -c 'exit 23' | tee artifacts/pipefail-negative-proof.log
negative=$?
bash -c 'exit 0' | tee artifacts/pipefail-positive-proof.log
positive=$?
printf '%s\n' "import test from 'node:test';" "import assert from 'node:assert/strict';" "test('controlled TEST failure',()=>assert.fail('intentional propagation proof'));" > "$fixture"
node --test "$fixture" | tee artifacts/pipefail-real-test-proof.log
real=$?
set -e
test "$negative" -eq 23
test "$positive" -eq 0
test "$real" -ne 0
printf 'producer=23 pipeline=%s\nsuccess_pipeline=%s\nreal_test_pipeline=%s\nFAILURE PROPAGATED\n' "$negative" "$positive" "$real" | tee artifacts/pipefail-proof-summary.log
