---
name: Release checklist
about: Track the steps for releasing a new version of a package (maintainers)
title: "Release <package> <version>"
type: Task
---

Steps for cutting a release. The animovement packages are published on [R-universe](https://animovement.r-universe.dev) rather than CRAN, so there is no submission step — R-universe rebuilds from `main`.

## Before

- [ ] `devtools::check()` passes locally, and CI is green on `main`
- [ ] The pkgdown site builds clean: `pkgdown::build_site()`, or at minimum the `pkgdown` workflow is green on `main`. Worth doing locally before a release, since a broken site is only noticed after it deploys
- [ ] `goodpractice::gp()` reviewed, and anything real either fixed or filed as an issue
- [ ] `devtools::test()` passes and coverage has not regressed
- [ ] `NEWS.md` polished — every user-facing change since the last release has a bullet, written for users rather than as a commit log, with issue references

## Version

Bump the version in **every** place that carries it:

- [ ] `DESCRIPTION` — drop the `.9000` development suffix
- [ ] `CITATION.cff` — `version` and `date-released`
- [ ] `inst/CITATION` — `version`, if the package has one
- [ ] `NEWS.md` — the `# (development version)` heading becomes `# <package> <version>`
- [ ] `README.md` — re-render it. The version is embedded in the startup banner and the citation block, so it goes stale silently:

  ```r
  # packages with a README.qmd
  quarto::quarto_render("README.qmd")     # or, in a terminal: quarto render README.qmd

  # packages with a README.Rmd
  devtools::build_readme()
  ```

  Re-install the package first (`devtools::install()`), otherwise the banner renders the *previously installed* version rather than the one you just bumped.

## Release

- [ ] Merge the release pull request
- [ ] Annotated tag on the merge commit: `git tag -a v<version> -m "<package> v<version>"` and push it
- [ ] Create the GitHub release from that tag. Name it descriptively — `v0.4.0 — one source of truth for dimensionality` — because the Zulip announcement uses the part after the version as its subtitle
- [ ] Check the announcement landed in **announcements > releases** on Zulip
- [ ] Confirm Zenodo minted a new version DOI, for packages with the Zenodo webhook

## After

- [ ] Bump `DESCRIPTION` to `<next version>.9000` and open a fresh `# (development version)` section in `NEWS.md`
- [ ] Re-render `README.md` so the embedded version matches
- [ ] Check the pkgdown site rebuilt and deployed
