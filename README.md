[Русская версия](README.ru.md)

# Claude-Codex Review Skill

Two AI agents review your plans and code iteratively — Claude Code as the initiator, Codex as an independent reviewer — catching issues that a single agent misses.

## Why dual review

A single AI agent tends to be consistent with itself: it makes the same assumptions throughout a task and rarely questions its own decisions. A second, independent agent breaks this pattern:

- **Blind spots** — each agent has different biases; cross-checking surfaces issues neither would find alone
- **Evidence discipline** — the protocol requires every issue to cite a specific file, method, or logic chain, filtering out vague "maybe" suggestions
- **Iterative convergence** — accepted issues are fixed and re-reviewed, rejected ones require explicit reasoning, so each round produces measurable progress
- **Audit trail** — every round is a markdown file in `.dual-review/`, giving a full decision history for the team

## Environment

This skill is optimized and tested for **Claude Code and Codex running as VS Code extensions** in the same workspace. Both agents share the project directory and read/write files directly.

This is not the MCP-based Codex integration or a CLI-mode workflow — it is a file-based protocol between two VS Code extension panels.

## How it works

A review session lives in `.dual-review/<session_id>/` and progresses through rounds:

```
R1-01-round-start.md     <- Claude prepares review context
R1-02-codex-claimed.flg  <- Codex claims the round
R1-03-codex-review.md    <- Codex writes structured review
R1-04-claude-claimed.flg <- Claude processes the review
```

Each round, Claude analyzes the feedback — accepting, rejecting, or inline-fixing each issue with explicit reasoning. If the verdict is `NEEDS_WORK`, Claude applies changes and opens a new round. The cycle continues until `APPROVED`, `REJECTED`, or `max_rounds` is reached, producing a `final.md` with the session outcome.

### Review scopes

| Scope | When to use |
|---|---|
| `plan-only` | Reviewing a plan before any code changes |
| `production-change` | Reviewing actual code changes |
| `architecture-check` | Evaluating an architectural decision |
| `lookup-test` | Verifying a hypothesis or API behavior |

### Quality contract

Every review enforces:
- Only significant issues — no stylistic nitpicks or weak hypotheses
- Each issue backed by evidence (file path, method name, logic)
- Explicit checks for missed requirements, regression risks, and over-engineering

## Installation

Copy the `claude-code/` directory into your project's skills:

```bash
mkdir -p .claude/skills/codex-dual-review-file-based
cp claude-code/* .claude/skills/codex-dual-review-file-based/
```

## Usage

In Claude Code:

```
/codex-dual-review-file-based <task description> [path/to/plan.md] [max_rounds=5]
```

Claude prepares the first round and prompts you to pass the reviewer instructions to Codex. A background file watcher detects when Codex completes its review and automatically triggers the next step.

## File structure

```
claude-code/
  SKILL.md              # Initiator protocol (Claude Code skill definition)
  reviewer-prompt.txt   # Reviewer protocol (prompt for Codex)
  wait-for-review.sh    # Background watcher script
docs/
  review-findings.md    # Protocol self-review (design decisions, edge cases)
```

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) as a VS Code extension
- [Codex](https://openai.com/index/codex/) as a VS Code extension (in the same workspace)
- Bash (for `wait-for-review.sh`)

## Limitations

- Codex must have read/write access to the `.dual-review/` directory in the project
- The `wait-for-review.sh` watcher polls every 10 seconds; not instant
- Session files are append-only by design — no file is ever overwritten or deleted during a session

## License

MIT
