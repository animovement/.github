# animovement 🦎
[![DOI](https://zenodo.org/badge/773406370.svg)](https://zenodo.org/doi/10.5281/zenodo.13235277)
[![R‑CMD‑check](https://github.com/animovement/animovement/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/animovement/animovement/actions/workflows/R-CMD-check.yaml)
[![animovement status badge](https://animovement.r-universe.dev/badges/animovement)](https://animovement.r-universe.dev)

_animovement_ is an open‑source R toolbox for analysing movement across space and time. It provides a modular, tidyverse‑friendly ecosystem of packages that cover the whole workflow—from importing raw tracking data to visualising and quantifying movement metrics. 

_animovement_ is designed for ethologists, behavioural ecologists, neuroscientists, biomechanicists and anyone who needs robust movement analysis tools. The suite follows a modular architecture, allowing you to pick just the components you need while still benefiting from a coherent, interoperable workflow.

## Packages
The *animovement* package consists of six core packages, each focused on a specific stage of the workflow:

| Package   | Status | Core purpose      | Short description                                                                                     |
|-----------|-----|-------------------|--------------------------------------------------------------------------------------------------------|
| [aniframe](https://github.com/animovement/aniframe)  | [![R-CMD-check](https://github.com/animovement/aniframe/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/animovement/aniframe/actions/workflows/R-CMD-check.yaml) | Data structures | Provides core data structures for movement data.                               |
| [aniread](https://github.com/animovement/aniread) | [![R-CMD-check](https://github.com/animovement/aniread/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/animovement/aniframe/actions/workflows/R-CMD-check.yaml)  | Import / Export   | Reads/writes data from video trackers, trackballs, and other sources.                                 |
| [anicheck](https://github.com/animovement/anicheck) | [![R-CMD-check](https://github.com/animovement/anicheck/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/animovement/anicheck/actions/workflows/R-CMD-check.yaml)  | Quality control   | Diagnostics for missing values, temporal gaps, and spatial outliers.                                 |
| [aniprocess](https://github.com/animovement/aniprocess) | [![R-CMD-check](https://github.com/animovement/aniprocess/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/animovement/aniprocess/actions/workflows/R-CMD-check.yaml) | Signal processing | Filtering, smoothing, and advanced trajectory processing.                                            |
| [animetric](https://github.com/animovement/animetric) | [![R-CMD-check](https://github.com/animovement/animetric/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/animovement/animetric/actions/workflows/R-CMD-check.yaml) | Metrics           | Calculates kinematics, navigation statistics, and social interaction measures.                       |
| [anivis](https://github.com/animovement/anivis) | [![R-CMD-check](https://github.com/animovement/anivis/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/animovement/anivis/actions/workflows/R-CMD-check.yaml) | Visualisation     | Publication‑ready plots of trajectories, diagnostics, and metrics.                                   |


## Documentation & Tutorials
- Website & tutorials: https://animovement.dev/animovement
- API reference: automatically generated via pkgdown for each package (accessible from the website).
- Examples: the repository includes example scripts and data sets under inst/examples.

## Contributing
We welcome contributions! Please read the full contribution guide in the repo’s CONTRIBUTING.md for detailed instructions.

Feel free to reach out if you have questions, suggestions, or want to collaborate—happy analysing!
