#!/bin/bash
# Ждёт появления файла ревью от Codex.
# Использование: wait-for-review.sh <session_id> <round_id>
# Пример: wait-for-review.sh 20260406-test-001 R2
SESSION_ID="$1"
ROUND_ID="$2"
TARGET=".dual-review/${SESSION_ID}/${ROUND_ID}-03-codex-review.md"
while [ ! -f "$TARGET" ]; do sleep 10; done
echo "${ROUND_ID} review ready: ${TARGET}"
