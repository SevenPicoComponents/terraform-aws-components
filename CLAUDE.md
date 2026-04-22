# SevenPico — terraform-aws-components

This file governs all Claude Code sessions in this repository. These rules override plugin defaults and apply to every task regardless of which plugins are loaded.

---

## Repo Identity

- **Org:** SevenPico
- **Repo:** `terraform-aws-components`
- **Purpose:** Reusable Terraform module library — all SevenPico platform modules and example stacks live here. No Terragrunt.
- **Main branch:** `main`
- **Integration branch:** `develop`

---

## What Lives Here

```
modules/       # Reusable Terraform modules — one directory per component
examples/      # Complete working examples for each module
PROMPTS/       # Runbooks, task prompts, and patterns
.github/       # CI workflows (tflint, fmt, validate)
```

No `common.hcl`, no `context.hcl`, no Terragrunt stages. This repo is pure Terraform module source code.

---

## Gitflow — Non-Negotiable Rules

**Claude Code must follow these rules for every change in this repo, no exceptions.**

### 1. Never commit directly to `develop` or `main`

All work goes through a feature branch:

```bash
git checkout develop
git pull origin develop
git checkout -b feature/<issue-number>-<short-description>
```

### 2. Every change requires a GitHub issue

Create one if it does not exist before starting work. Claim it:

```bash
gh issue edit <N> --add-assignee "@me"
gh issue edit <N> --remove-label "status: available" --add-label "status: in-progress"
```

### 3. Open a PR — never merge it yourself

After pushing the feature branch:

```bash
gh pr create --base develop --head feature/<N>-... --title "[type] description (#N)" --body "..."
```

Then **stop**. Post the PR URL to the user. Do not merge. **Claude Code must never merge a PR. The human merges.**

### 4. PR body must include `Closes #N`

### 5. Squash merge into `develop`

---

## Branch Naming

| Type | Pattern | Example |
|------|---------|---------|
| Feature | `feature/<N>-<slug>` | `feature/12-add-vpc-module` |
| Fix | `fix/<N>-<slug>` | `fix/15-s3-bucket-policy` |
| Chore | `chore/<N>-<slug>` | `chore/8-bump-provider-versions` |

---

## Module Standards

Every module under `modules/` must conform to the SevenPico terraform coding standards. Key rules:

- **Module priority**: SevenPico → SevenPicoForks → CloudPosse → local (strict order)
- **Context pattern**: always `module.context` — never `module.this`
- **No variable defaults** — all values come from the caller
- **Zero-safe** — every resource uses `count = module.<x>_context.enabled ? 1 : 0` or `for_each = module.context.enabled ? local.map : {}`
- **`_context.tf`** is always downloaded via curl, never hand-written
- **File naming**: `vpc.tf`, `iam.tf`, `s3.tf` — never `main.tf` or `resources.tf`

### Required file layout per module

```
modules/<name>/
  _context.tf      # curl from SevenPico/terraform-null-context — never hand-write
  _data.tf         # aws_region, aws_caller_identity, aws_partition + locals
  _locals.tf       # computed locals (omit only if none needed)
  _variables.tf    # type + description only, zero defaults
  _outputs.tf      # try() for zero-safe values
  <service>.tf     # resources named by AWS service
```

### Download _context.tf

```bash
curl -sL https://raw.githubusercontent.com/SevenPico/terraform-null-context/master/exports/_context.tf -o _context.tf
```

---

## Validation Workflow

Run this sequence after every `.tf` edit:

```bash
tflint
terraform fmt
terraform validate
```

Zero tolerance — all three must pass before committing.

---

## Required Skills — Load at Session Start

**Every Claude Code session in this repo must load these skills before doing any work:**

```
/7pi-aws-platform:platform-engineering-standards
/7pi-common:gitflow-workflow
```

`platform-engineering-standards` is the master activation skill — it loads terraform coding standards, module registry, and all SevenPico engineering conventions in one step.

| Skill | When to use |
|-------|-------------|
| `/7pi-aws-platform:platform-engineering-standards` | Every session — load first |
| `/7pi-common:gitflow-workflow` | Every session — load alongside platform standards |
| `/7pi-aws-platform:sevenpico-module-registry` | Before choosing any module source |
| `/7pi-aws-platform:terraform-coding-standards` | Before writing any `.tf` file (included in platform-engineering-standards) |

---

## Open Issues

| # | Description |
|---|-------------|
| [#1](https://github.com/SevenPico/terraform-aws-components/issues/1) | Initial repo scaffold — seed files and gitflow setup |

Keep this table current as issues are opened and closed.
