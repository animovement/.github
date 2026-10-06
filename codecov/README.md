# Codecov configuration

Every package reports coverage to Codecov through the shared `test-coverage`
workflow, and every package should be configured the same way. Rather than a
`codecov.yml` in each repository, the settings live once, in Codecov's
**Global YAML** for the animovement organisation, which applies to every
repository that does not override it.

Codecov keeps that setting in its own web app, not in git. `codecov.yml` here is
the canonical copy, so changes to it are versioned and reviewed like anything
else. **Codecov does not read this file**: GitHub's organisation defaults cover
community files such as issue templates, not tool configuration.

## What it sets

- **Project and patch status** at `target: auto` and `threshold: 1%`, marked
  `informational: true`. Codecov reports them on every pull request and never
  fails them. They are not required checks in any repository either.
- **`comment: require_changes: true`**. Codecov comments on a pull request only
  when it changes coverage, so a pull request that leaves coverage alone sends
  no notification.

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

A package does not need a `codecov.yml`. If one has a file, Codecov merges it
over the Global YAML key by key, so whatever it sets wins. Only add one for a
setting that really applies to that package alone, and say why in it.
