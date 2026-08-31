# Workflow stubs

Every package repository runs the same CI, and the *jobs* already live here as
reusable workflows — `pkgdown.yml`, `r-cmd-check.yml`, `test-coverage.yml` and
the rest under `.github/workflows/`. What cannot live here is the **triggers**:
GitHub decides when a workflow runs from the `on:` block of the file in the
repository where it runs, and a `workflow_call` workflow has no say in its
callers' triggers. So each repository carries a short stub — an `on:` block and
a `uses:` line — and those stubs are what drift.

They had. `pkgdown.yaml` was `pull_request: branches: [main]` in seven
repositories and unfiltered in anicore, which meant a stacked pull request never
ran the check in those seven; since pkgdown is a required check, one that never
runs blocks the merge for good (see #31). Nothing reported the difference,
because nothing was comparing them.

`stubs/` holds the canonical copy of each. **Sync workflow stubs** renders them
into every repository in `agents/packages.tsv` and opens a pull request wherever
a copy differs, in the same shape as **Sync AGENTS.md**.

## Changing a stub

Edit the file in `stubs/`, merge, and the workflow runs on push. Or run it by
hand from the Actions tab — `dry_run` reports what would change without opening
anything.

Do not edit a stub in a package repository: the next sync opens a pull request
putting it back.

## The token

Writing to `.github/workflows/` in another repository needs more than the usual
token. `GITHUB_TOKEN` is scoped to this repository, and even a personal token
must carry the **workflow** scope. Without it the API refuses the write:

```
gh: refusing to allow a Personal Access Token to create or update workflow
    `.github/workflows/pkgdown.yaml` without `workflow` scope (HTTP 403)
```

That is what the first run hit. The sync reuses `AGENTS_SYNC_TOKEN`, created for
`AGENTS.md`, which does not need the scope — so it has to be added there:

- **Classic token** — tick `workflow` alongside `repo`.
- **Fine-grained token** — set *Workflows* to **Read and write**, for every
  repository the sync writes to.

The restriction applies to `git push` as well as to the API, so there is no way
around it from inside the workflow. It reports the missing scope by name and
carries on to the next repository, so one run tells you about every repository
rather than the first.

## What is deliberately not synced

`release-to-zulip.yml` is here too, but a repository is free to opt out by
deleting it — the sync only updates a stub that already exists, and never
creates one. A new package still needs its stubs copying in once, which is what
`packaging.md` describes.
