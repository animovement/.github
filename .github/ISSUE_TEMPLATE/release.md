---
name: Release checklist
about: Track the steps for releasing a new version of a package (maintainers)
title: "Release <package> <version>"
type: Task
projects: ["animovement/1"]
---

Steps for cutting a release. The animovement packages are published on [R-universe](https://animovement.r-universe.dev) rather than CRAN, so there is no submission step — R-universe rebuilds from `main`.

## Before

- [ ] `devtools::check()` passes locally, and CI is green on `main`
- [ ] The pkgdown site builds clean: `pkgdown::build_site()`, or at minimum the `pkgdown` workflow is green on `main`. Worth doing locally before a release, since a broken site is only noticed after it deploys
- [ ] `goodpractice::gp()` reviewed, and anything real either fixed or filed as an issue
- [ ] `devtools::test()` passes and coverage has not regressed
- [ ] `NEWS.md` polished — every user-facing change since the last release has a bullet, written for users rather than as a commit log, with issue references
- [ ] `recipes/<package>/recipe.yaml` in [animovement-forge](https://github.com/animovement/animovement-forge) lists the same dependencies as `DESCRIPTION`, floors included, under both `host` and `run`. Its nightly job updates only the version and the commit, so dependencies drift unless changed by hand; fix them there before the release is built

## Version

Bump the version in **every** place that carries it:

- [ ] `DESCRIPTION` — drop the development suffix (`.9000`, `.9001`, …)
- [ ] `CITATION.cff` — `version` and `date-released`
- [ ] `NEWS.md` — the `# <package> (development version)` heading becomes `# <package> <version> (YYYY-MM-DD)`
- [ ] `README.md`, **animovement only**: re-render it. It is the only README that embeds a version, in the startup banner and the citation block, so it goes stale silently. The other packages' READMEs carry no version and need nothing:

  ```r
  quarto::quarto_render("README.qmd")     # or, in a terminal: quarto render README.qmd
  ```

  Re-install the package first (`devtools::install()`), otherwise the banner renders the *previously installed* version rather than the one you just bumped.

`inst/CITATION` needs no change: every package reads its version from `DESCRIPTION` with `meta$Version`.

## Release

- [ ] Merge the release pull request
- [ ] Annotated tag on the commit the release landed as on `main`: `git tag -a v<version> -m "<package> v<version>"` and push it. Every release so far was merged with a merge commit and tagged there; pull requests in the packages have since been squash-merged, in which case the squash commit is the one to tag
- [ ] Create the GitHub release from that tag. Name it descriptively — `v0.4.0 — one source of truth for dimensionality` — because the Zulip announcement uses the part after the version as its subtitle
- [ ] Check the announcement landed in **announcements > releases** on Zulip
- [ ] Confirm Zenodo minted a new version DOI, for packages with the Zenodo webhook
- [ ] Confirm R-universe built the released version: `https://animovement.r-universe.dev/<package>`. Allow it several minutes after the merge. Do this, and the conda check below, before merging the post-release bump: R-universe builds only what is on `main`, and animovement-forge only what R-universe currently has
- [ ] Confirm the conda package reached [prefix.dev](https://prefix.dev/channels/animovement). animovement-forge's **Nightly Check** workflow picks up new R-universe versions once a day; to publish sooner, run it by hand from the [Actions tab](https://github.com/animovement/animovement-forge/actions/workflows/nightly-check.yml). Running **Build and Upload** on its own rebuilds the recipes as they are, without moving them to the new version

## After

- [ ] Bump `DESCRIPTION` to `<next version>.9000` and open a fresh `# <package> (development version)` section in `NEWS.md`
- [ ] animovement only: re-render `README.md` so the embedded version matches
- [ ] Check the pkgdown site rebuilt and deployed
