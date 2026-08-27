#!/usr/bin/env bash
# Vendor the canonical agent-facing documents into animovement-agents, where a
# coding agent can read them as files rather than having to fetch a URL — many
# cannot fetch, and those that can will often skip it.
#
# The copies are generated. Each carries the commit it came from, so a stale one
# identifies itself rather than being quietly trusted.
#
# Usage: agents/sync-agent-docs.sh [--dry-run]
# Requires: GH_TOKEN able to write to animovement/animovement-agents.

set -euo pipefail

repo="animovement/animovement-agents"
branch="chore/sync-agent-docs"
dest="skills/animovement-dev/reference"
dry_run=false
[ "${1:-}" = "--dry-run" ] && dry_run=true

sha=$(git rev-parse HEAD)
short=${sha:0:7}
today=$(date -u +%Y-%m-%d)

# source path -> destination basename
map="
CONTRIBUTING.md|contributing.md|CONTRIBUTING.md
AI.md|ai-policy.md|AI.md
.github/ISSUE_TEMPLATE/release.md|release-checklist.md|.github/ISSUE_TEMPLATE/release.md
.github/PULL_REQUEST_TEMPLATE.md|pull-request-template.md|.github/PULL_REQUEST_TEMPLATE.md
"

# Strip the leading provenance block for comparison, so a run where nothing has
# actually changed does not churn a pull request just because the date moved.
#
# Only the block at the very start of the file: PULL_REQUEST_TEMPLATE.md carries
# six HTML comments of its own, and removing those would hide a change to the
# template's guidance from this comparison. `sed '1{...}'` is not portable — BSD
# sed rejects it, and a silently empty result would make every file compare equal.
strip_provenance() {
  awk 'NR==1 && $0=="<!--" {inh=1; next} inh && $0=="-->" {inh=0; next} !inh' |
    sed '/./,$!d'
}

# Provenance block. Every vendored file carries one, so a copy that has fallen
# behind its source identifies itself instead of being quietly trusted.
header() {
  local origin="$1"
  printf '%s\n' \
    "<!--" \
    "  Generated from $origin in animovement/.github — do not edit here." \
    "  Edit it there; the Sync agent docs workflow opens a pull request with the change." \
    "" \
    "  Source: https://github.com/animovement/.github/blob/main/$origin" \
    "  Commit: $sha" \
    "  Synced: $today" \
    "" \
    "  This copy can lag its source. If a detail matters, check the URL above." \
    "-->" \
    ""
}

# A straight copy: strip any YAML frontmatter (the release checklist is an issue
# template and carries some), then prepend provenance.
render() {
  local src="$1" origin="$2"
  awk 'NR==1 && $0=="---" {fm=1; next} fm && $0=="---" {fm=0; next} !fm' "$src" |
    sed '/./,$!d' |
    cat <(header "$origin") -
}

# The bug and feature templates are GitHub issue *forms*: YAML that applies only in
# the web UI, and that cannot be passed to `gh issue create --body`. Rendering them
# to a markdown skeleton is the only way an agent opening an issue through the API
# can reproduce the fields.
render_issue_forms() {
  ./agents/render-issue-forms.rb \
    .github/ISSUE_TEMPLATE/bug_report.yml \
    .github/ISSUE_TEMPLATE/feature_request.yml \
    .github/ISSUE_TEMPLATE/task.yml |
    cat <(header ".github/ISSUE_TEMPLATE/{bug_report,feature_request,task}.yml") -
}

declare -a paths=() contents=()
changed=0

while IFS='|' read -r src name origin; do
  [ -z "$src" ] && continue
  rendered=$(render "$src" "$origin")
  target="$dest/$name"

  # Compare ignoring the provenance block, so an unchanged document does not
  # churn a pull request every time this runs.
  current=$(gh api "repos/$repo/contents/$target" --jq '.content' 2>/dev/null | base64 -d 2>/dev/null || true)
  if [ -n "$current" ] && [ "$(printf '%s' "$current" | strip_provenance)" = "$(printf '%s' "$rendered" | strip_provenance)" ]; then
    echo "unchanged: $target"
    continue
  fi

  echo "would update: $target"
  changed=$((changed + 1))
  paths+=("$target")
  contents+=("$rendered")
done <<<"$map"

# Same staleness comparison for the generated file, which has no single source.
rendered=$(render_issue_forms)
target="$dest/issue-templates.md"
current=$(gh api "repos/$repo/contents/$target" --jq '.content' 2>/dev/null | base64 -d 2>/dev/null || true)
if [ -n "$current" ] && [ "$(printf '%s' "$current" | strip_provenance)" = "$(printf '%s' "$rendered" | strip_provenance)" ]; then
  echo "unchanged: $target"
else
  echo "would update: $target"
  changed=$((changed + 1))
  paths+=("$target")
  contents+=("$rendered")
fi

if [ "$changed" -eq 0 ]; then
  echo "everything up to date"
  exit 0
fi

# A plugin is pinned to the version string in its manifest: an install only picks
# up new content when that changes. Syncing the reference documents without
# bumping it ships a skill nobody receives — which is what happened to the five
# commits that preceded 0.4.0. So the sync bumps its own patch version.
#
# Both manifests carry the version and scripts/check.sh asserts they agree, so
# they move as a pair. They are read from the default branch, the same base the
# commit below is built on, so a run against an already-open sync branch
# recomputes the same bump rather than compounding it.
version_of() {
  printf '%s' "$1" | sed -n 's/^[[:space:]]*"version": "\([^"]*\)".*/\1/p' | head -1
}

manifests=(plugin.json .claude-plugin/plugin.json)
declare -a manifest_bodies=()
version=""

for m in "${manifests[@]}"; do
  body=$(gh api "repos/$repo/contents/$m" --jq '.content' 2>/dev/null | base64 -d 2>/dev/null || true)
  [ -n "$body" ] || { echo "::error::cannot read $m from $repo"; exit 1; }

  v=$(version_of "$body")
  case "$v" in
    [0-9]*.[0-9]*.[0-9]*) ;;
    *) echo "::error::$m has no usable version (got '${v:-none}')"; exit 1 ;;
  esac

  if [ -z "$version" ]; then
    version="$v"
  elif [ "$v" != "$version" ]; then
    # check.sh would fail the pull request anyway; failing here says why.
    echo "::error::manifests disagree: $version vs $v. Reconcile them before syncing."
    exit 1
  fi

  manifest_bodies+=("$body")
done

IFS=. read -r v_major v_minor v_patch <<<"$version"
next_version="$v_major.$v_minor.$((v_patch + 1))"
echo "would bump: $version -> $next_version"

for i in "${!manifests[@]}"; do
  # Rewrite the version line alone. A JSON round-trip would reformat the rest as
  # well — key order, and the \u2014 the description escapes — burying the one
  # line that actually changed.
  bumped=$(printf '%s' "${manifest_bodies[$i]}" |
    sed -E "s/^([[:space:]]*\"version\": \")[^\"]*(\",?)$/\1$next_version\2/")
  [ "$(version_of "$bumped")" = "$next_version" ] ||
    { echo "::error::failed to rewrite the version in ${manifests[$i]}"; exit 1; }

  paths+=("${manifests[$i]}")
  contents+=("$bumped")
done

if [ "$dry_run" = true ]; then
  echo "dry run — $changed file(s) and the version would change"
  exit 0
fi

# animovement-agents is public and is not one of the eight packages, so a token
# scoped to those alone reads everything above without complaint and then fails
# on the first blob with a bare 403. Say what to fix instead.
if [ "$(gh api "repos/$repo" --jq '.permissions.push // false' 2>/dev/null)" != "true" ]; then
  echo "::error::GH_TOKEN cannot write to $repo. Add that repository to the token's access, with Contents and Pull requests write. See agents/README.md."
  exit 1
fi

base_sha=$(gh api "repos/$repo/git/ref/heads/main" --jq '.object.sha')
base_tree=$(gh api "repos/$repo/git/commits/$base_sha" --jq '.tree.sha')

# One tree and one commit for all files. Committing through the contents API
# instead would produce a separate commit per file.
tree_args=()
for i in "${!paths[@]}"; do
  # -F, not -f, for the content: only the typed flag reads `@-` from standard
  # input, and the raw one would post the two characters as the file. -f, not
  # -F, for the tree fields: the typed flag turns 100644 into a JSON number and
  # the API requires a string ("Must supply a valid tree.mode").
  blob=$(printf '%s\n' "${contents[$i]}" | gh api "repos/$repo/git/blobs" \
    -F content=@- -f encoding=utf-8 --jq '.sha')
  tree_args+=(-f "tree[][path]=${paths[$i]}" -f "tree[][mode]=100644" \
              -f "tree[][type]=blob" -f "tree[][sha]=$blob")
done

tree=$(gh api "repos/$repo/git/trees" -f base_tree="$base_tree" "${tree_args[@]}" --jq '.sha')
commit=$(gh api "repos/$repo/git/commits" \
  -f message="docs: sync agent-facing documents from animovement/.github@$short

Bumps the plugin to $next_version so installs pick the change up." \
  -f tree="$tree" -f parents[]="$base_sha" --jq '.sha')

gh api -X POST "repos/$repo/git/refs" -f ref="refs/heads/$branch" -f sha="$commit" >/dev/null 2>&1 ||
  gh api -X PATCH "repos/$repo/git/refs/heads/$branch" -f sha="$commit" -F force=true >/dev/null

if [ -z "$(gh pr list -R "$repo" --head "$branch" --state open --json number --jq '.[0].number')" ]; then
  gh pr create -R "$repo" --base main --head "$branch" \
    --title "docs: sync agent-facing documents from animovement/.github" \
    --body "$(printf '%s\n' \
      "Vendored copies of the canonical documents, regenerated from [animovement/.github@\`$short\`](https://github.com/animovement/.github/commit/$sha)." \
      "" \
      "They live beside the \`animovement-dev\` skill so an agent can read them as files rather than fetching a URL. Do not edit them here — edit the source in \`animovement/.github\` and this workflow will open the next pull request." \
      "" \
      "Also bumps the plugin to \`$next_version\` in both manifests. A plugin is pinned to its version string, so without that this content would not reach anyone who has it installed." \
      "" \
      "Opened automatically by [Sync agent docs](https://github.com/animovement/.github/actions/workflows/sync-agent-docs.yml).")" >/dev/null
  echo "pull request opened"
else
  echo "existing pull request updated"
fi
