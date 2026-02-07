---
name: gitignore-profile-generator
description: Generate annotated .gitignore files by composing reusable target templates.
version: 0.1.0
license: Apache-2.0
---

# Gitignore Profile Generator

## Purpose

Generate a comprehensive `.gitignore` by composing multiple language, framework, and tool targets. The skill is script-heavy by design: each script does one job and composes through stdin/stdout pipelines.

## Scripts Overview

| Script | Responsibility |
| --- | --- |
| `scripts/install.sh` | Verify required CLI dependencies and print setup guidance. |
| `scripts/parse.sh` | Parse comma/newline-separated targets into normalized, deduplicated target names. |
| `scripts/generate.sh` | Expand normalized targets into annotated ignore-rule sections from template data. |
| `scripts/format.sh` | Deduplicate repeated non-comment patterns and normalize blank lines. |
| `scripts/run.sh` | Main entry point that orchestrates `parse -> generate -> format`. |
| `scripts/test.sh` | Validate list, generation, composition, deduplication, and error behavior. |

## Pipeline Examples

```bash
# Basic usage
./scripts/run.sh node,macos,vscode

# Compose scripts manually
printf "node\nreact\n" \
  | ./scripts/parse.sh \
  | ./scripts/generate.sh \
  | ./scripts/format.sh

# Read targets from stdin
printf "python\nterraform\n" | ./scripts/run.sh

# List supported targets
./scripts/run.sh --list
```

## Inputs and Outputs

- `scripts/parse.sh`
  - Input: args or stdin (`node,macos` and/or newline-separated values)
  - Output: one normalized target per line on stdout
- `scripts/generate.sh`
  - Input: normalized target names on stdin (or args)
  - Output: annotated `.gitignore` sections on stdout
- `scripts/format.sh`
  - Input: `.gitignore` content on stdin
  - Output: cleaned `.gitignore` content on stdout
- `scripts/run.sh`
  - Input: args or stdin targets
  - Output: final `.gitignore` text on stdout

## Environment Variables

- `TEMPLATE_FILE`: Optional path to the template JSON map. Defaults to `data/templates.json`.
- `REQUIRED_TOOLS`: Optional space-separated dependency override for `scripts/install.sh`.