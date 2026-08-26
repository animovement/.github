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
- For any user-facing change, add a bullet to `NEWS.md` under `# (development version)`. See *Changelogs* below.

Every pull request runs `R CMD check` on Linux, macOS and Windows, builds the pkgdown site, reports test coverage, and checks formatting. All of these must pass before merging.

### Commit messages

We follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/), so that release notes can be drafted from the history and version bumps follow from what actually changed.

```
<type>(<optional scope>): <description>
```

The types we use:

| Type | Use for | Version effect |
|---|---|---|
| `feat` | A new user-facing capability — an exported function, a new argument | Minor |
| `fix` | A bug fix in behaviour a user could hit | Patch |
| `docs` | Roxygen comments, vignettes, README, this guide | None |
| `perf` | A change that makes existing behaviour faster | Patch |
| `refactor` | Internal restructuring with no change in behaviour | None |
| `test` | Adding or correcting tests | None |
| `build` | `DESCRIPTION`, dependencies, packaging | None |
| `ci` | Workflows and their stubs | None |
| `chore` | Anything else that touches no user-facing behaviour | None |
| `revert` | Undoing an earlier commit | Matches what it undoes |

A **breaking change** — a removed or renamed export, a changed default, a different return type — takes a `!` before the colon (`feat(aniframe)!: …`) and a `BREAKING CHANGE:` footer explaining the migration. Those are the ones that force a major bump, so they are worth spelling out.

The scope is optional and is normally the package name (`fix(aniread): …`), or the area within a package when that is more useful (`fix(read_sleap): …`).

- Write the description in the imperative — *add*, not *added* or *adds* — and lower-case, with no trailing full stop.
- Describe the change, not the file: `fix(aniprocess): keep metadata through filter_kalman()` rather than `fix: update filter-kalman.R`.

**The pull request title must follow the same format**, and matters more than the individual commits: merges here squash, so the title becomes the commit that lands on `main`. A workflow checks it, and will tell you what is wrong. Commits within a branch are squashed away, so tidy them if you like, but do not agonise over them.

`NEWS.md` is still written by hand, for users — the commit history drafts release notes, it does not replace them. The types above map onto the changelog sections described in *Changelogs*.

### Changelogs

`NEWS.md` is a changelog: a summary of what changed, written for the person
deciding whether to upgrade and what they will have to fix. It is not a commit
log, and it is not where the reasoning goes — why a change was made belongs in
the issue, the pull request, or a blog post.

Headings follow the R convention; sections follow
[Keep a Changelog](https://keepachangelog.com/en/2.0.0/).

```markdown
# aniframe (development version)

## Fixed

* `set_unit_space()` converts the length axes of the frame's coordinate system
  rather than whichever of `x`, `y` and `z` are present (#98). `rho` is a length
  on polar, cylindrical and spherical frames and was never converted, while the
  metadata was updated to claim the new unit.

# aniframe 0.7.0 (2026-08-18)

## Added

* `validate_aniframe()` re-checks that the metadata still describes the frame
  (#79). Counterpart to `validate_anievent()`.

## Changed

* `set_metadata()` no longer writes the `variables_*` fields; use their
  dedicated setters (#82). Writing them as plain metadata left the frame grouped
  as before, so operations silently integrated across identities.
```

**Headings are `# <package> <version> (YYYY-MM-DD)`.** Not Keep a Changelog's
`## [0.7.0] - 2026-08-18`: pkgdown builds each package's changelog page by
matching the R form, and the bracketed one fails with *"no version headings
found"* ([pkgdown#2749](https://github.com/r-lib/pkgdown/issues/2749)).
`# <package> (development version)` is the Unreleased section, opened by the
post-release step and renamed at the next release.

**Sections are Keep a Changelog's six**, used only when they have content:
`Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`. They line up
with the commit types above, so `feat` lands in *Added*, `fix` in *Fixed*.

- A **breaking change** is not its own section. It goes under `Changed` or
  `Removed`, and the bullet says what breaks and what to do about it — which is
  what a reader needs, and reads better than a heading that only says something
  broke.
- **There is no `Internal` section**, and "internal" is not the test. What
  matters is whether a change is observable by someone using the package. A
  refactor nobody can detect gets no entry; the same refactor that makes
  something measurably faster goes under `Changed`, described by its effect
  rather than its mechanism. Keep a Changelog's own example is *"Rewrote JSON
  parser; 3x faster on large files"*, filed under `Changed` rather than given a
  `Performance` section of its own — there are six sections on purpose. This
  mirrors the commit types: a `perf` commit usually earns an entry, a
  `refactor` usually does not.
- **Documentation**: a new article or a sweeping change goes under `Added`.
  Reference-index tweaks and wording fixes get no entry.

**Length is whatever the change needs.** A one-line fix takes one line; a new
class earns a paragraph and a code block. What does *not* belong is the
reasoning: how the bug was found, what was considered and rejected, why the old
design was wrong. Compare

```markdown
* `set_metadata()` no longer writes the `variables_*` fields; use their
  dedicated setters (#82). Writing them as plain metadata left the frame grouped
  as before, so operations silently integrated across identities.
```

with the same entry carrying its own history — *"which is the desynchronisation
#82 closed"*, *"the cast was also redundant, since `mutate()` has preserved class
and metadata since #81"*. Both are true; only the first is a changelog.

**Reference the issue or pull request** in parentheses before the full stop, so a
reader can get from the summary to the detail. **Credit contributors** with
`@username` alongside it — `(#123, @contributor)` — for anyone who is not a
maintainer of the package.

For wording — where to put the function name, backticks, present tense, ordering
within a section — follow the
[tidyverse NEWS guide](https://style.tidyverse.org/news.html).
[aniframe's `NEWS.md`](https://github.com/animovement/aniframe/blob/main/NEWS.md)
is the worked example of all of the above.

### Two commands that save round trips

Comment on your pull request and a maintainer-triggered workflow will fix things for you:

- **`/document`** re-runs roxygen and pushes the regenerated `man/` and `NAMESPACE`.
- **`/style`** reformats the package with air and pushes the result.

Both require a maintainer to run them, so ask in the pull request if you would like them applied.

### Code style

We follow the [tidyverse style guide](https://style.tidyverse.org) — for code here, and for
documentation in the next section.

- **Formatting** is handled by [air](https://posit-dev.github.io/air/), which implements that guide,
  so the two never disagree. Every pull request is checked and suggestions are posted inline. Please
  do not reformat code unrelated to your change.
- **Documentation** uses [roxygen2](https://roxygen2.r-lib.org) with Markdown syntax. Edit the
  roxygen comments in `R/`, never the generated `.Rd` files in `man/`.
- **Tests** use [testthat](https://testthat.r-lib.org). Contributions that come with tests are much
  easier to accept.
- **Before a substantial change lands**, it is worth running [goodpractice](https://docs.ropensci.org/goodpractice/) over the package:

  ```r
  # install.packages("goodpractice")
  goodpractice::gp()          # from the package root
  ```

  It includes lintr, and by default that means a lot of formatting complaints that air already
  settles. To keep the useful checks without the noise:

  ```r
  formatting <- c(
    "brace", "commas", "function_left_parentheses", "indentation", "infix_spaces",
    "line_length", "paren_body", "pipe_consistency", "pipe_continuation", "quotes",
    "semicolon", "spaces_inside", "spaces_left_parentheses", "trailing_blank_lines",
    "trailing_whitespace", "whitespace"
  )
  noisy <- paste0("tidyverse_", formatting, "_linter")
  goodpractice::gp(checks = setdiff(goodpractice::all_checks(), noisy))
  ```

  That drops 16 formatting checks and keeps the semantic ones — `tidyverse_seq_linter`, which
  catches `1:length(x)` counting backwards on empty input, is worth the price of admission on
  its own.

  It runs `R CMD check`, lintr, cyclomatic complexity and coverage together, and reports things like print methods that don't return invisibly, unused internal functions, or untested code. Read it critically rather than treating every line as a defect — it flags `.onAttach` as uncalled, and counts roxygen comments as over-long lines. It is not part of CI for that reason.

- Function naming follows the verb prefixes each package owns — `read_`, `filter_`, `calculate_`, `check_`, `plot_` and so on. Match the surrounding code.

### Benchmarks

Most functions here do not need timing. A handful — the filters in
[aniprocess](https://github.com/animovement/aniprocess), the metrics in
[animetric](https://github.com/animovement/animetric) — are heavy enough that a
change can quietly make them much slower, and heavy enough that nobody notices
until someone runs them on a real dataset.

For those, a package keeps a `bench/` directory of plain R scripts:

```
bench/
  filter_across.R
  filter_ccma.R
```

`bench/` is listed in `.Rbuildignore` and nothing in it is referenced from
`DESCRIPTION`, so it is invisible to `R CMD check` and adds no dependency. It is
a developer tool, not part of the package.

**Benchmarks are run by hand, when you touch the function.** There is no CI job.
These functions change rarely, so a benchmark on every pull request would cost
more than it caught. What makes that work is a marker comment in `R/`, directly
above the function and below its roxygen block:

```r
#' @return An aniframe with the spatial columns smoothed.
#' @export
# Benchmark: bench/filter_across.R
filter_across <- function(data, ...) {
```

That line is the whole mechanism. It tells you the benchmark exists before you
edit the function, rather than after someone reports a slowdown. `grep -rn
"# Benchmark:" R/` lists what is covered. One script can cover several related
functions — mark each of them, pointing at the same file.

#### Writing one

Use [bench](https://bench.r-lib.org). `bench::press()` sweeps the parameters,
`bench::mark()` times the expressions inside each combination:

```r
# bench/filter_across.R — run with: Rscript bench/filter_across.R
devtools::load_all(quiet = TRUE)

results <- bench::press(
  n_individuals = c(10, 50, 250),
  n_obs = c(100, 500),
  {
    af <- aniframe::example_aniframe(
      n_obs = n_obs,
      n_individuals = n_individuals,
      n_keypoints = 1
    )
    bench::mark(
      rollmean = filter_across(af, "rollmean", window_width = 11),
      excursion = filter_na_across(af, "excursion"),
      check = FALSE,
      min_iterations = 3
    )
  }
)

print(results[c("expression", "n_individuals", "n_obs", "median", "mem_alloc")], n = Inf)
```

**Vary size, not just settings.** Sweeping two sizes is what separates "this got
slower" from "this got slower *the bigger it gets*", and the second is the one
that ruins someone's afternoon. For movement data the two axes are almost always
**number of tracks** (individuals × keypoints) and **trajectory length** (rows
per track); a function can be linear in one and quadratic in the other. The run
above says something useful precisely because it sweeps both:

| expression | individuals | rows | median |
|---|---|---|---|
| rollmean | 10 | 100 | 9.8ms |
| rollmean | 250 | 100 | 88.9ms |
| rollmean | 10 | 500 | 11.1ms |
| rollmean | 250 | 500 | 94.2ms |
| excursion | 10 | 500 | 16.8ms |
| excursion | 250 | 500 | 216.6ms |

`filter_across()` with `"rollmean"` barely notices five times the rows — its cost
is per group. `filter_na_across()` with `"excursion"` pays for both. A one-size
benchmark would have reported one of those numbers and told you neither thing.

Keep it under a minute. `min_iterations = 3` and a top size that still finishes
quickly is enough; a benchmark nobody waits for is a benchmark nobody runs. Set
`check = FALSE` when the expressions return different things.

#### Reporting one

Run the script on `main`, run it on your branch, and put **both tables in the
pull request**. Timings are only comparable within one machine, which is why
results are not committed — a checked-in baseline from someone else's laptop
invites exactly the comparison that does not mean anything.

If the change is user-visible, the headline number belongs in `NEWS.md` too. A
deliberate slowdown is fine and sometimes correct — say so and say why, because
an accidental one of the same size looks identical from the outside.

**Timing assertions do not belong in `tests/`.** A test like

```r
expect_true(time["elapsed"] < 1)
```

measures the CI runner as much as the code: it fails for reasons unrelated to
your change, and a 3× slowdown that still comes in under a second passes
silently. Move it to `bench/`.

### Documentation style

We follow the [tidyverse guide to documentation](https://style.tidyverse.org/documentation.html):
titles in sentence case without a full stop, `@param` and `@return` written as sentences,
cross-links in preference to code font, `@noRd` on internal functions, `@family` to group related
ones. It is short, and it pairs with the code style above — air implements the same guide, so the
formatter and the written rules cannot disagree.

Everything below is what that guide does not cover.

**Every exported function needs an example and a `@return`.** Examples are executed by
`R CMD check`, so they are the part of the documentation that cannot quietly stop being true. Run
them with `devtools::run_examples()`.

**Document defaults in the parameter.** "A logical value (default `TRUE`) determining whether…"
rather than leaving the reader to find it in the signature.

**Examples take an aniframe from `example_aniframe()`**, at the smallest shape that makes the point:

```r
#' @examples
#' af <- aniframe::example_aniframe(n_obs = 5, n_individuals = 1, n_keypoints = 1)
#' map_to_polar(af)
```

**Namespace that call.** Under `R CMD check` only the documented package is attached, so an
unqualified `example_aniframe()` fails everywhere except in aniframe itself. For functions taking
plain vectors or data frames, write the input inline.

**`@return` should name what changed.** Nearly everything here returns an aniframe, so the type
alone says little:

```r
#' @return An aniframe with `rho` and `phi` in place of `x` and `y`.
```

not "An aniframe" or "The transformed data".

**Avoid `\dontrun{}`.** It hides the example from `R CMD check`, so it rots unnoticed. Reserve it
for examples that genuinely cannot run there — network access, a file the user supplies, something
interactive — and prefer `@examplesIf` where the condition can be tested.

**Where documentation belongs.** Function reference lives with the code as roxygen comments.
Tutorials spanning several packages live on [animovement.dev](https://animovement.dev) — see
*Contributing documentation* below.

### Issues and pull requests

Please use the templates. They exist so that a report has what is needed to act on it — a reproducible example and `animovement_sitrep()` output for a bug, the *why* rather than the *what* for a pull request. Filling them in properly is the single biggest thing that gets a contribution reviewed quickly. This applies equally if you are drafting with an AI assistant: complete the template rather than replacing it with generated prose. See the [AI use policy](AI.md).

Maintainers cutting a release should open a **Release checklist** issue from the template and work through it.

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
