# terraform-aws-components

SevenPico's reusable Terraform module library. All platform modules and example stacks for the SevenPico multi-account AWS architecture live here.

## Structure

```
modules/       Reusable Terraform modules (one directory per component)
examples/      Complete working examples for each module
PROMPTS/       Runbooks, task prompts, and architecture patterns
.github/       CI/CD workflows
```

## Module Catalog

| Module | Purpose |
|--------|---------|
| *(modules will be added via feature branches)* | |

## Usage

Each module under `modules/` is a self-contained Terraform component. Reference via git source:

```hcl
module "core" {
  source = "git::git@github.com:SevenPico/terraform-aws-components.git//modules/app-core?ref=v0.1.0"
  context = module.context.self
  # ...
}
```

## Development

See [CLAUDE.md](./CLAUDE.md) for coding standards and gitflow rules.

### Validation

```bash
cd modules/<name>
tflint
terraform fmt -check
terraform validate
```

## Versioning

Follows [Semantic Versioning](https://semver.org/):

| Increment | When |
|-----------|------|
| PATCH | Bugfixes; no new resources |
| MINOR | New features; backward-compatible additions |
| MAJOR | Breaking changes; destructive operations |
