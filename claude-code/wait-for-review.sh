#!/bin/bash
# Ждёт появления файла ревью от Codex.
# Использование: wait-for-review.sh <session_id> <round_id>
# Пример: wait-for-review.sh 20260406-test-001 R2
# Скрипт определяет корень проекта через расположение самого скрипта:
# .claude/skills/codex-dual-review-file-based/wait-for-review.sh → корень в ../../..
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
SESSION_ID="$1"
ROUND_ID="$2"
TARGET="${PROJECT_ROOT}/.dual-review/${SESSION_ID}/${ROUND_ID}-03-codex-review.md"
while [ ! -f "$TARGET" ]; do sleep 10; done
echo "${ROUND_ID} review ready: ${TARGET}"
