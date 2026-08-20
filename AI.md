# AI use policy and guidelines

## In short

We are humans who enjoy working with other humans. Use whatever tools you like, but you are ultimately responsible for the changes you submit. Don't submit changes you haven't carefully read through yourself, and let us have a conversation with you, not a chatbot.

## Introduction

Our goal in animovement is to build software that scientists can trust with their data. That requires careful attention to detail in every change we integrate. Maintainer time is very limited, so changes you ask us to review should represent your *best* work.

You can use any tools that help you understand the codebase and write good code, including AI tools. But you always need to make a sincere effort to understand and explain the changes you're proposing, whether or not an LLM was part of producing them. The answer to "why is this an improvement?" should never be "I'm not sure, the AI did it."

> [!WARNING]
> **Do not allow AI agents to submit pull requests for you**, and **do not submit an AI-generated pull request you haven't personally understood and tested**. This wastes maintainer time. Pull requests that appear to violate this guideline will be closed without review.

## Using AI as a coding assistant

1. Don't skip **becoming familiar with the part of the codebase** you're working on. This lets you write better prompts and judge their output. Code assistants are a useful discovery tool, but don't trust claims they make about how animovement works — LLMs are often wrong, even about details the documentation answers clearly. When in doubt, ask on [Zulip](https://animovement.zulipchat.com).

2. **Verify that functions exist, and check their signatures against the source.** This matters more here than in most projects. animovement is a suite of eight packages that has been through a split and continues to evolve, so plausible-sounding function names may belong to a different package than an LLM claims, may have changed signature, or may never have existed. If a suggested call looks reasonable but you haven't seen it in the source or the reference documentation, assume it is wrong until checked.

3. **Give your assistant the real documentation rather than letting it guess.** Every package site publishes its documentation as markdown, which any assistant can read:

   - `https://animovement.dev/<package>/llms.txt` — the README, then a complete index of every exported function, grouped by purpose with a one-line description of each, then the articles. A good place to start when you need to know what a package offers.
   - `https://animovement.dev/<package>/reference/<function>.md` — the full help page for one function, including its exact signature.

   These are generated from the roxygen comments in the source, so unlike a model's recollection they cannot drift from the installed package. Checking a signature there takes seconds and settles the question.

   What they do not give you is the shape of the ecosystem — which of the eight packages owns a given job, or how we work across them. Where a repository has an `AGENTS.md`, that is the entry point for that, and [animovement-agents](https://github.com/animovement/animovement-agents) holds the ecosystem map itself: which package owns what, the aniframe data model, and the naming conventions.

4. Try to submit changes in **small, self-contained pull requests**, even if an LLM generated them all in one go.

5. Don't simply ask an LLM to add **code comments**. It will produce text that explains what is already clear from the code. If you do use one, be specific, demand succinctness, and edit the result.

6. **Run the tests.** `devtools::test()` locally, and read what CI reports on your pull request. Generated code that passes review by looking plausible is exactly the code that fails on real data.

7. **Fill in the templates yourself.** Issue and pull request templates ask for the things that make a report actionable — a reproducible example, the reasoning behind a change. Replacing a template with generated prose is worse than leaving it blank, because it looks complete without being so.

## Using AI for communication

Contributors are expected to communicate with intention, rather than spending maintainer time on long, sloppy writing. We much prefer clear and concise notes on points that actually need discussion over long AI-generated comments.

If you use an LLM to write a message, it remains **your responsibility** to read the whole thing and make sure it makes sense and represents your ideas. A good rule of thumb: if you can't make yourself carefully read some LLM output you generated, nobody else will want to read it either.

1. When writing a pull request description, **don't include anything obvious** from the diff — which files changed, which functions were touched. Focus on the *why*. Don't ask an LLM to write the description from your diff; it will just restate what is already visible.

2. When responding to a review comment, **explain *your* reasoning**.

3. Verify that **everything you write is accurate**. We cannot review contributions that misrepresent what the code does, what it was tested against, or what effect it has.

4. Complete all parts of the **pull request template**, rather than overwriting it with generated text.

5. **Clarity and succinctness matter more than perfect grammar.** Don't feel obliged to pass your writing through an LLM — English does not have to be your first language for your contribution to be welcome. If you do, make sure it doesn't get longer in the process.

6. Quoting an LLM is usually less useful than linking to **primary sources** — the source code, or the reference documentation. If you do quote one, put it in a quote block so it is clearly distinguishable from your own thoughts.

## For maintainers

The same standard applies to us. Where a commit or pull request was produced with substantial AI assistance, say so in the description — a trailer such as `Co-Authored-By:` or a note at the end of the pull request body is enough. The point is not ceremony; it is that someone reading the history later can tell what was reviewed by a human and what to look at more closely.

## Acknowledgements

*This guide is adapted, with minor modifications, from the [napari AI use policy](https://napari.org/dev/developers/contributing/ai.html), which is in turn adapted from the [Zulip policy on AI use](https://github.com/zulip/zulip/blob/main/CONTRIBUTING.md#ai-use-policy-and-guidelines). Our thanks to both teams for their work in support of open source.*
