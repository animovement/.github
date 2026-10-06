# Codecov configuration

Every package reports coverage to Codecov through the shared `test-coverage`
workflow, and every package should be configured the same way. Rather than a
`codecov.yml` in each repository, the settings live once, in Codecov's
**Global YAML** for the animovement organisation, which applies to every
repository that has no `codecov.yml` of its own.

Codecov keeps that setting in its own web app, not in git. `codecov.yml` here is
the canonical copy, so changes to it are versioned and reviewed like anything
else. **Codecov does not read this file**: GitHub's organisation defaults cover
community files such as issue templates, not tool configuration.

## What it sets

- **Project and patch status** at `target: auto` and `threshold: 1%`, marked
  `informational: true`. Codecov reports them on every pull request and never
  fails them. They are not required checks in any repository either.
- **`comment: require_changes: "coverage_drop OR uncovered_patch"`**. Codecov
  comments on a pull request only when project coverage drops or the pull
  request adds lines the tests do not cover. Otherwise it stays quiet and sends
  no notification. `require_changes: true` is not the same: it comments on any
  change to the coverage report, including new lines that are fully covered, so
  every pull request that adds tested code would still get a comment.

## Changing it

1. Edit `codecov.yml` here and merge the pull request.
2. As an organisation admin, open the animovement organisation's settings at
   [app.codecov.io](https://app.codecov.io), go to **Global YAML**, paste the
   file in and save.

Check it first with Codecov's validator:

```sh
curl --data-binary @codecov/codecov.yml https://codecov.io/validate
```

## Package repositories

A package does not have a `codecov.yml`, and should not get one. Codecov does
not merge a repository's file with the Global YAML: a repository with its own
`codecov.yml` ignores the Global YAML entirely. A file added for one setting
would therefore drop the shared statuses and comment rule for that package, and
it would have to copy them, which is the drift this setup exists to avoid.
