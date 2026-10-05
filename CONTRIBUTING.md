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
| [anicore](https://github.com/animovement/anicore) | The core data structures and metadata |
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

You do not need renv to contribute, but you will meet it. Every package carries an `renv.lock` and an `.Rprofile` that sources `renv/activate.R`, so starting R in a package directory activates renv: it installs renv if it is missing and switches to a project library, separate from your usual one. CI switches this off with `RENV_CONFIG_AUTOLOADER_ENABLED=false` and resolves dependencies from `DESCRIPTION`, and the lockfiles are not kept in step with `DESCRIPTION`. To work the way CI does, set the same variable before R starts — in `~/.Renviron` (`usethis::edit_r_environ()` opens it), which turns renv's autoloader off for every project:

```
RENV_CONFIG_AUTOLOADER_ENABLED=false
```

### Pull requests

Please submit changes as a pull request against `main`.

- Create a branch for your work. `usethis::pr_init("brief-description")` sets this up.
- Keep a pull request to one logical change. Several small ones are easier to review, and get merged faster, than one large one.
- The title is a Conventional Commit, the same format as a commit message (see *Commit messages*); the body should say why the change is needed.
- If it closes an issue, put `Fixes #issue-number` in the body.
- For any user-facing change, add a bullet to `NEWS.md` under `# <package> (development version)`. See *Changelogs* below.

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

A **breaking change** — a removed or renamed export, a changed default, a different return type — takes a `!` before the colon (`feat(anicore)!: …`) and a `BREAKING CHANGE:` footer explaining the migration. Those are the ones that force a major bump, so they are worth spelling out.

The scope is optional and is normally the package name (`fix(aniread): …`), or the area within a package when that is more useful (`fix(read_sleap): …`).

- Write the description in the imperative — *add*, not *added* or *adds* — and lower-case, with no trailing full stop.
- Describe the change, not the file: `fix(aniprocess): keep metadata through filter_kalman()` rather than `fix: update filter-kalman.R`.

**The pull request title must follow the same format.** Pull requests in the package repositories are squash-merged, so each lands on `main` as one commit, and how that commit is written follows GitHub's squash settings there:

- **With more than one commit**, the commit takes the pull request's title, and its body is the branch's commit messages, listed in order. They stay in the history, so write them to be read.
- **With a single commit**, the commit keeps that commit's own message, title included, and the pull request title is not used. [aniread#133](https://github.com/animovement/aniread/pull/133) was titled `fix(aniread): …` and landed as `fix: …`. Make the commit's first line the title you want on `main` — amend it, or have whoever merges edit it in the merge dialog.
- **The pull request description never reaches `main`.** A `BREAKING CHANGE:` footer belongs in a commit message, not only in the description.

In animovement/.github and animovement-agents, a workflow checks the title and tells you what is wrong. The package repositories do not run that check, so a reviewer checks it there.

`NEWS.md` is still written by hand, for users — the commit history drafts release notes, it does not replace them. The types above map onto the changelog sections described in *Changelogs*.

### Changelogs

`NEWS.md` is a changelog: a summary of what changed, written for the person
deciding whether to upgrade and what they will have to fix. It is not a commit
log, and it is not where the reasoning goes — why a change was made belongs in
the issue, the pull request, or a blog post.

Headings follow the R convention; sections follow
[Keep a Changelog](https://keepachangelog.com/en/2.0.0/).

```markdown
# anicore (development version)

## Fixed

* `set_unit_space()` converts the length axes of the frame's coordinate system
  rather than whichever of `x`, `y` and `z` are present (#98). `rho` is a length
  on polar, cylindrical and spherical frames and was never converted, while the
  metadata was updated to claim the new unit.

# anicore 0.7.0 (2026-08-18)

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
[anicore's `NEWS.md`](https://github.com/animovement/anicore/blob/main/NEWS.md)
is the worked example of all of the above.

### What CI checks

Every package runs the same CI, from shared workflows in [animovement/.github](https://github.com/animovement/.github). On every pull request, whatever branch it targets:

- **`R-CMD-check`** runs `R CMD check` with the current R release on Ubuntu, macOS and Windows, and with the previous release (`oldrel-1`) on Ubuntu. Pushes to `main` add R-devel on Ubuntu, which has no binary packages and so is kept off pull requests.
- **`anicore-metadata-contract`**, a job in the same workflow, refuses raw access to anicore's metadata outside anicore. See *anicore's metadata* below.
- **`pkgdown`** builds the site. It deploys only outside pull requests: on pushes to `main`, on releases, and when run by hand.
- **`test-coverage`** runs the tests under covr and uploads the result to Codecov.
- **`format-suggest`** runs air over the pull request and posts what it would change as suggestions. It fails if air would change anything at all.

`main` is protected by a ruleset that requires seven of these to pass before merging: the four `R-CMD-check` jobs, `pkgdown`, `test-coverage` and `format-suggest`. The `anicore-metadata-contract` job and Codecov's statuses are not required, so read them rather than relying on the merge button.

**Coverage.** Codecov reports `codecov/patch` — how much of the changed code the tests exercise. It never blocks a merge (every package except animovement marks it informational in its `codecov.yml`, and in none is it a required check), but keep it at 100%: recent pull requests have covered every line they add. If a line genuinely cannot be tested, say so in the pull request.

### Stacked pull requests

A change that builds on another that has not been merged yet can be stacked: each pull request targets the branch of the one below it. The required checks run whatever branch a pull request targets, so every layer is checked on its own.

Maintainers manage stacks with [GitHub's stacked pull requests](https://gh.io/stacks), through the `gh stack` extension to the GitHub CLI. Merging a stack lands each layer on `main` as its own squash commit, in order — so every layer needs its own Conventional Commit title, and its own matching commit message if it has a single commit (see *Commit messages*).

If a lower layer is merged on its own instead, the layer above still targets the old branch, and still carries that layer's original commits. GitHub retargets it only when the merged branch is deleted, and these repositories do not delete branches on merge. Rebase it onto `main`, push, and retarget the pull request yourself:

```sh
git fetch origin
git rebase --onto origin/main <old-tip-of-the-lower-branch> <upper-branch>
git push --force-with-lease origin <upper-branch>
gh pr edit <number> --base main
```

### Development versions

Between releases a package's version is the last release plus a fourth component — `0.8.0.9000`, then `.9001`, `.9002` and so on. Most pull requests leave it alone. Bump the last component when a change has to be visible outside the repository:

- **Another package will require it.** A package can only depend on code by version, so a pull request adding something another package will use bumps the development version itself ([anicore#171](https://github.com/animovement/anicore/pull/171)), and the dependent package raises its floor to that version.
- **It has to reach the conda channel.** The conda packages on [prefix.dev](https://prefix.dev/channels/animovement) are built nightly by [animovement-forge](https://github.com/animovement/animovement-forge) from what R-universe has built, and a version already on the channel is not uploaded again. A change merged without a bump therefore does not reach conda users. A maintainer catches these up with a separate pull request, `chore(<package>): bump development version to <version>`, covering everything merged since the last bump ([animetric#75](https://github.com/animovement/animetric/pull/75)).

### Depending on another animovement package

- **Raise the floor** in `DESCRIPTION` when you use something that is new in another package of the suite — `anicore (>= 0.8.0.9004)` for a function that arrived in that version ([animetric#86](https://github.com/animovement/animetric/pull/86)).
- **Wait for R-universe.** CI installs the other suite packages from [R-universe](https://animovement.r-universe.dev), not from GitHub. R-universe rebuilds a package after its `main` changes (anicore 0.8.0.9004 was published nine minutes after it merged), and until it has, a floor naming the new version cannot be met and the checks fail while installing dependencies. Once the version shows on `https://animovement.r-universe.dev/<package>`, re-run the failed jobs.
- **Mirror the dependency in the conda recipe.** The recipes in animovement-forge list their dependencies by hand; the nightly job updates only the version and the commit. A new dependency or a raised floor needs the same change in `recipes/<package>/recipe.yaml` there, under both `host` and `run`.

### Function lifecycle

Every package uses [lifecycle](https://lifecycle.r-lib.org) to say how settled a function is ([.github#46](https://github.com/animovement/.github/issues/46)).

- **Unlabelled means stable.** Only functions that are not get a badge; badging every page would be noise. A stable function changes only through a deprecation cycle.
- **`experimental`** marks a new interface that has not been used in anger yet, and may change without a deprecation cycle — that is what the label is for. Use it for genuinely new designs ([aniprocess's `*_across()`](https://animovement.dev/aniprocess/reference/filter_across.html)), and drop it once the interface has settled.
- **`superseded`** marks a function with a better alternative that is kept indefinitely. It does not warn; its help page points to the replacement.
- **`deprecated`** marks a function on its way out. It warns, keeps its old behaviour exactly, and is removed after **one release**.

The badge is the first line of the description, generated by lifecycle:

```r
#' Summarise each trajectory as a whole
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' Measures of a path that are not a statistic of any per-row column ...
```

To deprecate a function, call `lifecycle::deprecate_warn()` with the package's next release as `when`, and forward to the replacement:

```r
summarise_tortuosity <- function(data) {
  lifecycle::deprecate_warn("0.6.0", "summarise_tortuosity()", "summarise_path()")
  summarise_path(data)
}
```

- Use `deprecate_soft()` instead for something only package authors call; it warns them, not the users of their packages ([anicore's old `aniframe()` names](https://github.com/animovement/anicore/blob/main/R/deprecated.R)).
- Give it the `deprecated` badge and `@keywords internal`, so it leaves the reference index, and list it under *Deprecated* in `NEWS.md` with its replacement.
- Test that it warns and still returns what it did: `expect_warning(old(x), class = "lifecycle_warning_deprecated")`, compared against the replacement's output.
- Removing it after the next release is a breaking change, with a `!` and a `BREAKING CHANGE:` footer like any other.

Each package is set up the way aniprocess is: `lifecycle` in `Imports`, `#' @importFrom lifecycle deprecated` in the package-level documentation, and the badge images in `man/figures/`. `usethis::use_lifecycle()` does not recognise our `Config/roxygen2/version` setup, so a new package copies the images from aniprocess rather than generating them, and adds `r-lifecycle` to its conda recipe.

### anicore's metadata

Outside anicore, read and write an aniframe's metadata only through anicore's accessors — `get_metadata()`, `set_metadata()`, `get_variables()`, `get_keys()`, `get_index()` and the other `get_*()` and `set_*()` functions. anicore is free to change how it stores metadata because nothing else depends on the layout ([anicore#155](https://github.com/animovement/anicore/issues/155)); raw access is what once turned a single layout change into a migration across the whole suite.

The `anicore-metadata-contract` job enforces this in every package but anicore. It searches the `.R` files in `R/` — not `tests/`, and not lines that are only a comment — for `attr(…, "metadata")`, `$variables_what` (and `_when`, `_where`, `_index`, `_event`), and the same fields accessed with `[[`. A line that genuinely needs the raw attribute opts out with a trailing `# anicore: allow-metadata` comment on that same line. air moves a comment that trails an opening `{` onto the next line, out of the check's sight, so put the raw read in an assignment of its own:

```r
stored <- attr(x, "metadata") # anicore: allow-metadata
if (is.null(stored)) {
```

### Two commands that save round trips

A comment on a pull request starting with one of these runs a workflow that fixes things for you:

- **`/document`** re-runs roxygen and pushes the regenerated `man/` and `NAMESPACE`.
- **`/style`** reformats the package with air and pushes the result.

They act only on comments from members and owners of the animovement organisation, and ignore everyone else's, so ask in the pull request if you would like them applied.

### Code style

We follow the [tidyverse style guide](https://style.tidyverse.org) — for code here, and for
documentation in the next section.

- **Formatting** is handled by [air](https://posit-dev.github.io/air/), which implements that guide,
  so the two never disagree. Every pull request is checked and suggestions are posted inline, and
  the check (`format-suggest`) is required: it fails if air would change anything. Please do not
  reformat code unrelated to your change.
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
  noisy <- c(
    paste0("tidyverse_", formatting, "_linter"),
    "lintr_duplicate_argument_linter"
  )
  goodpractice::gp(checks = setdiff(goodpractice::all_checks(), noisy))
  ```

  That drops 16 formatting checks and keeps the semantic ones — `tidyverse_seq_linter`, which
  catches `1:length(x)` counting backwards on empty input, is worth the price of admission on
  its own.

  It also drops `lintr_duplicate_argument_linter`, which misreads cli's repeated `"i" =` bullets
  in `cli::cli_abort(c(...))` as an argument passed twice. Those are named elements of a
  character vector, and repeating the name is how cli asks for several bullets, so every
  multi-line message written the way this guide asks trips it. Leave those calls as they are.

  It runs `R CMD check`, lintr, cyclomatic complexity and coverage together, and reports things like print methods that don't return invisibly, unused internal functions, or untested code. Read it critically rather than treating every line as a defect — it flags `.onAttach` as uncalled, and counts roxygen comments as over-long lines. It is not part of CI for that reason.

- Function naming follows the verb prefixes each package owns — `read_`, `filter_`, `calculate_`, `check_`, `plot_` and so on. Match the surrounding code.

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
#' af <- anicore::example_aniframe(n_obs = 5, n_individuals = 1, n_keypoints = 1)
#' map_to_polar(af)
```

**Namespace that call.** Under `R CMD check` only the documented package is attached, so an
unqualified `example_aniframe()` fails everywhere except in anicore itself. For functions taking
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

Please use the templates. They exist so that a report has what is needed to act on it — a reproducible example and `animovement_sitrep()` output for a bug, the *why* rather than the *what* for a pull request. Filling them in properly is the single biggest thing that gets a contribution reviewed quickly. This applies equally if you are drafting with an AI assistant: complete the template rather than replacing it with generated prose. See the [AI use policy](https://github.com/animovement/.github/blob/main/AI.md).

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

This project is released with a [Contributor Code of Conduct](https://github.com/animovement/.github/blob/main/CODE_OF_CONDUCT.md). By contributing, you agree to abide by its terms.
