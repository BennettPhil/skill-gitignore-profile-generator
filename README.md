# gitignore-profile-generator

Generate annotated `.gitignore` files from composable target templates.

## Prerequisites

- `bash`
- `jq`
- `awk`
- `sed`
- `grep`

## Install / Validate Environment

```bash
./scripts/install.sh
```

## Usage

```bash
./scripts/run.sh node,macos,vscode
```

```bash
printf "python\nterraform\n" | ./scripts/run.sh
```

```bash
./scripts/run.sh --list
```

## Compose Individual Scripts

```bash
printf "node,react\n" \
  | ./scripts/parse.sh \
  | ./scripts/generate.sh \
  | ./scripts/format.sh
```

## Run Tests

```bash
./scripts/test.sh
```