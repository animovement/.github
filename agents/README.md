# Agent-facing files

`AGENTS.md` is the entry point coding agents read — Claude Code, Codex, Cursor and others all look
for it in the repository they are working in. It has to be a real file in each package repository:
GitHub's organisation-wide inheritance only affects what the website renders, so an inherited file
is **not** present in a clone and an agent never sees it.

This directory keeps one authored copy so the eight are not maintained separately.

| File | Purpose |
| --- | --- |
| `AGENTS.md.tmpl` | The template. `{{PACKAGE}}` and `{{ROLE}}` are substituted per package. |
| `packages.tsv` | The packages, tab-separated: name, then the role that fills `{{ROLE}}`. |

Adding a package to the suite means adding one line to `packages.tsv`.

## Making a change

Edit the template (or `packages.tsv`) and merge. The **Sync AGENTS.md** workflow runs on any push to
`main` that touches either file, and opens a pull request against every package whose copy is out of
date. It can also be run by hand from the Actions tab, with a **dry run** option that reports what
would change without opening anything.

Repositories already up to date are skipped, so re-running it is harmless.

## The token it needs

`GITHUB_TOKEN` is scoped to the repository it runs in, so it cannot write to the package
repositories. The workflow needs a personal access token, stored here as a secret named
`AGENTS_SYNC_TOKEN`.

**Create it:**

1. Go to **Settings → Developer settings → Personal access tokens → Fine-grained tokens**, or
   directly to <https://github.com/settings/personal-access-tokens/new>.
2. **Token name**: something identifiable, e.g. `animovement AGENTS.md sync`.
3. **Resource owner**: `animovement`, not your personal account. If the organisation has not enabled
   fine-grained tokens, do that first under the organisation's **Settings → Personal access tokens**;
   the token may also need approving there after you create it.
4. **Expiration**: your call. The workflow fails loudly when the token expires, rather than silently
   doing nothing, so a shorter expiry is safe.
5. **Repository access**: *Only select repositories* → the eight packages. Do not grant access to all
   repositories; this token only ever writes `AGENTS.md`.
6. **Permissions** → *Repository permissions*:
   - **Contents**: Read and write — to create the branch and commit the file
   - **Pull requests**: Read and write — to open the pull request
   - Metadata (read) is added automatically
7. Generate, and copy the token — it is shown once.

**Store it:**

In `animovement/.github` → **Settings → Secrets and variables → Actions → New repository secret**.
Name it `AGENTS_SYNC_TOKEN` and paste the value. A repository secret is enough; there is no need for
an organisation-wide one, since only this workflow uses it.

A classic token with the `repo` scope also works, but grants far more than this needs.

## Why pull requests rather than direct pushes

`main` is protected in every package, requiring a pull request and passing checks. The token belongs
to an admin and could bypass that, but then a sync would push straight to eight default branches
unreviewed. Opening pull requests keeps the protection meaningful and makes each change visible. They
are trivial to merge, and only appear when something actually changed.
