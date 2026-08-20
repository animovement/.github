---
name: Bug report
about: Something in an animovement package does not work as expected
title:
labels: bug
---

**Describe the bug**
A clear and concise description of what the bug is.

**Reproducible example**
Please include a [minimal reproducible example](https://reprex.tidyverse.org/articles/learn-reprex.html) — the smallest piece of code that shows the problem. The [reprex](https://reprex.tidyverse.org) package makes this easy:

```r
# install.packages("reprex")
reprex::reprex({
  library(animovement)
  # your code here
})
```

If the problem involves a particular data file, please say which tracking tool produced it, and attach a small excerpt if you are able to share one.

**Expected behaviour**
What you expected to happen instead.

**Session information**
Please paste the output of `animovement_sitrep()`, which reports your R version and the version of every animovement package:

```r
animovement::animovement_sitrep()
```

If animovement itself will not load, `sessionInfo()` is the next best thing.

**Additional context**
Anything else that might help — screenshots, the full error message, or what you were trying to achieve.
