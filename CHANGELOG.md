# Changelog

All notable changes to this project will be documented in this file.

This project uses a lightweight Keep a Changelog style. Dates are in UTC.

## [Unreleased]

## [2026-04-23]
### Added
- Added `CHANGELOG.md` to track notable repository changes.

### Changed
- Clarified Codex runtime behavior in `claude-code/reviewer-prompt.txt`: round and session summaries must go through `commentary`, `final` is reserved for true completion, and Step 8 requires a real poll-and-sleep wait loop.

## [2026-04-16]
### Changed
- Updated the initiator flow to use `Monitor` instead of Bash `run_in_background` for waiting on review completion.

## [2026-04-10]
### Changed
- Synced the English and Russian README files with protocol and documentation updates.
- Removed outdated license references from the documentation.

## [2026-04-09]
### Added
- Initial public release of the file-based dual-review skill for Claude Code + Codex.
- Added the core skill files in `claude-code/` and the supporting documentation in `docs/`.
