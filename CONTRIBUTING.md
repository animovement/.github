# Contributing to animovement

Contributions are very welcome — whether fixing a bug, adding a feature, or improving the documentation. This guide applies to every repository in the [animovement](https://github.com/animovement) organisation.

**If your favourite type of movement data is not supported yet, we would love a sample of your data so we can support it.** That is one of the most useful contributions you can make.

## Before you start

Check the issue tracker to see whether an issue already describes what you have in mind.

- If it does, comment to say you would like to work on it.
- If it does not, open one describing your idea.

If you use AI tools while contributing, please read the [AI use policy and guidelines](https://github.com/animovement/.github/blob/main/AI.md) first. Short version: use whatever tools you like, but understand and test what you submit, and talk to us yourself.

We strongly encourage discussing your plans before writing code — in the issue, or on our [Zulip chat](https://animovement.zulipchat.com). This avoids duplicated effort and makes sure the work fits where the project is going. If you are not sure whether an issue is ready to be worked on, just ask.

### Which repository?

animovement is a suite of packages, each owning one stage of the pipeline:

| Package | Owns |
|---|---|
| [aniframe](https://github.com/animovement/aniframe) | The core data structures and metadata |
| [aniread](https://github.com/animovement/aniread) | Reading and writing movement data |
| [anicheck](https://github.com/animovement/anicheck) | Data-quality diagnostics |
| [aniprocess](https://github.com/animovement/aniprocess) | Signal processing and filtering |
| [anispace](https://github.com/animovement/anispace) | Spatial transformations |
| [animetric](https://github.com/animovement/animetric) | Movement metrics |
| [anivis](https://github.com/animovement/anivis) | Visualisation |
| [animovement](https://github.com/animovement/animovement) | The meta-package that bundles them |

File the issue against the package that owns the behaviour. If you are unsure, open it against [animovement](https://github.com/animovement/animovement/issues) and we will move it.

## Contributing code

### Setting up

Fork and clone the repository, then install the package with its dependencies. The animovement packages are published on [R-universe](https://animovement.r-universe.dev) rather than CRAN, so that repository has to be named:

```r
options(repos = c(
  animovement = "https://animovement.r-universe.dev",
  CRAN = "https://cloud.r-project.org"
))
# install.packages("pak")
pak::pak()          # dependencies of the package in the working directory
devtools::load_all()
devtools::test()
```

Some repositories carry an `renv.lock`. You do not need renv to contribute — it records a known-good set of versions for reproducing a specific environment, and CI resolves dependencies from `DESCRIPTION` rather than from the lockfile.

### Pull requests

Please submit changes as a pull request against `main`.

- Create a branch for your work. `usethis::pr_init("brief-description")` sets this up.
- Keep a pull request to one logical change. Several small ones are easier to review, and get merged faster, than one large one.
- The title should briefly describe the change; the body should say why it is needed.
- If it closes an issue, put `Fixes #issue-number` in the body.
- For any user-facing change, add a bullet to `NEWS.md` under `# (development version)`, in the style described in the [tidyverse NEWS guide](https://style.tidyverse.org/news.html).

Every pull request runs `R CMD check` on Linux, macOS and Windows, builds the pkgdown site, reports test coverage, and checks formatting. All of these must pass before merging.

### Two commands that save round trips

Comment on your pull request and a maintainer-triggered workflow will fix things for you:

- **`/document`** re-runs roxygen and pushes the regenerated `man/` and `NAMESPACE`.
- **`/style`** reformats the package with air and pushes the result.

Both require a maintainer to run them, so ask in the pull request if you would like them applied.

### Code style

- **Formatting** is handled by [air](https://posit-dev.github.io/air/). Every pull request is checked, and suggestions are posted inline. Please do not reformat code unrelated to your change.
- **Documentation** uses [roxygen2](https://roxygen2.r-lib.org) with Markdown syntax. Edit the roxygen comments in `R/`, never the generated `.Rd` files in `man/`.
- **Tests** use [testthat](https://testthat.r-lib.org). Contributions that come with tests are much easier to accept.
- Function naming follows the verb prefixes each package owns — `read_`, `filter_`, `calculate_`, `check_`, `plot_` and so on. Match the surrounding code.

## Contributing documentation

Documentation is split deliberately:

- **Function reference** lives with the code, as roxygen comments, on each package's own site.
- **Tutorials and guides that span packages** live on [animovement.dev](https://animovement.dev), in the [website repository](https://github.com/animovement/animovement.github.io).

So a fix to what a function does belongs in the package; a new worked example belongs on the hub.

## Getting help

- [Zulip](https://animovement.zulipchat.com) for questions and discussion.
- The issue tracker of the relevant package for bugs and feature requests.

## Code of Conduct

This project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing, you agree to abide by its terms.
