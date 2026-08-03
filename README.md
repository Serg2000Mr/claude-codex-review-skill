[Русская версия](README.ru.md)

# Claude-Codex Review Skill

This skill lets Claude Code and Codex review a plan or code change through a crash-resilient file protocol. Claude Code initiates the session, Codex acts as an independent reviewer, and both agents use the same project directory without an MCP server or CLI bridge.

## Quick start

Copy the complete `claude-code/` directory into the project skill directory:

```bash
mkdir -p .claude/skills/codex-dual-review-file-based
cp claude-code/* .claude/skills/codex-dual-review-file-based/
```

Then run in Claude Code:

```text
/codex-dual-review-file-based <task description> [path/to/plan.md] [max_rounds=5]
```

Claude Code creates the first round and prints one ready-to-use instruction for Codex. Codex keeps watching the same session for later rounds; the user does not need to pass the prompt again.

## How it works

Each session lives in an absolute `<project_root>/.dual-review/<session_id>/` directory. If Claude Code runs inside a Git worktree, the session remains inside that worktree.

```text
R1-01-round-start.md     <- Claude writes the review contract
R1-02-codex-claimed.flg  <- Codex claims the round
R1-03-codex-review.md    <- Codex writes the review
R1-04-claude-claimed.flg <- Claude processes the result
final.md                 <- Claude records the session outcome
```

Round-start and review files contain a machine-readable JSON block plus a human-readable explanation. Claude verifies every finding as a hypothesis, applies accepted changes before opening the next round, and records rejected findings with evidence.

The session ends with:

- `approved` after `APPROVED`;
- `failed` after the rare `REJECTED` verdict;
- `limit` when `max_rounds` is reached.

`APPROVED` alone does not finish a session: `final.md` is the completion marker.

## Protocol guarantees

- Session files are append-only: protocol files are never overwritten or deleted.
- Absolute `SESSION_DIR`, reviewer-prompt, and helper-script paths prevent main-checkout/worktree mix-ups.
- Claim flags allow interrupted agents to resume from files instead of reconstructing state from chat.
- Review scope is fixed in round 1 and cannot drift between rounds.
- JSON fields provide a stable contract for verdicts, severity, confidence, evidence, and finding IDs.
- Missing or malformed review JSON is reported as a recoverable protocol error instead of being guessed from prose.

## Review scopes

| Scope | When to use |
|---|---|
| `plan-only` | Review a plan before code changes |
| `production-change` | Review actual code and tests |
| `architecture-check` | Evaluate an architectural decision |
| `lookup-test` | Verify a hypothesis or API behavior |

## Environment

The protocol requires Claude Code and Codex to have read/write access to the same project directory. It works with project-local or global skill installation because the prompt and wait scripts are resolved from the loaded `SKILL.md` directory.

Use the bundled helper that matches the environment:

- `wait-for-review.ps1` on Windows with PowerShell;
- `wait-for-review.sh` on macOS, Linux, or Git Bash.

Both helpers accept an absolute session directory, validate the round, use adaptive polling, return a compact JSON result, and stop after a configurable timeout.

## Design decisions

- **Different model, independent assumptions.** A second agent is useful because it does not automatically preserve the initiator's blind spots.
- **Findings are hypotheses.** Claude accepts, rejects, or fixes each finding with explicit reasoning; reviewer suggestions are not commands.
- **Round-start is a contract.** Claims about completed changes must match the actual files listed for review.
- **Files are the source of truth.** A restarted agent resumes from `.dual-review/<session_id>/`, not from chat history.

## Repository structure

```text
claude-code/
  SKILL.md              # Claude Code initiator protocol
  reviewer-prompt.txt   # Codex reviewer protocol
  wait-for-review.ps1   # Windows wait helper
  wait-for-review.sh    # Bash wait helper
docs/
  review-findings.md    # Historical self-review of the original protocol
```

## Limitations

- This repository implements Claude Code as initiator and Codex as reviewer; the reverse direction is outside its current scope.
- Both agents must keep access to the same project or worktree for the duration of the session.
- File polling is intentionally simple and may detect a transition a few seconds after it occurs.
- A session can run for up to five rounds by default.
