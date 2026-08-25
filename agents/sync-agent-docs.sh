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
"

# Build the vendored copy of one file: strip any YAML frontmatter (the release
# checklist is an issue template and carries some), then prepend provenance.
render() {
  local src="$1" origin="$2"
  awk 'NR==1 && $0=="---" {fm=1; next} fm && $0=="---" {fm=0; next} !fm' "$src" |
    sed '/./,$!d' |
    cat <(printf '%s\n' \
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
      "") -
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
  strip() { sed '1{/^<!--$/,/^-->$/d}' | sed '/./,$!d'; }
  if [ -n "$current" ] && [ "$(printf '%s' "$current" | strip)" = "$(printf '%s' "$rendered" | strip)" ]; then
    echo "unchanged: $target"
    continue
  fi

  echo "would update: $target"
  changed=$((changed + 1))
  paths+=("$target")
  contents+=("$rendered")
done <<<"$map"

if [ "$changed" -eq 0 ]; then
  echo "everything up to date"
  exit 0
fi

if [ "$dry_run" = true ]; then
  echo "dry run — $changed file(s) would change"
  exit 0
fi

base_sha=$(gh api "repos/$repo/git/ref/heads/main" --jq '.object.sha')
base_tree=$(gh api "repos/$repo/git/commits/$base_sha" --jq '.tree.sha')

# One tree and one commit for all files. Committing through the contents API
# instead would produce a separate commit per file.
tree_args=()
for i in "${!paths[@]}"; do
  blob=$(printf '%s' "${contents[$i]}" | gh api "repos/$repo/git/blobs" \
    -f content=@- -f encoding=utf-8 --jq '.sha')
  tree_args+=(-F "tree[][path]=${paths[$i]}" -F "tree[][mode]=100644" \
              -F "tree[][type]=blob" -F "tree[][sha]=$blob")
done

tree=$(gh api "repos/$repo/git/trees" -f base_tree="$base_tree" "${tree_args[@]}" --jq '.sha')
commit=$(gh api "repos/$repo/git/commits" \
  -f message="docs: sync agent-facing documents from animovement/.github@$short" \
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
      "Opened automatically by [Sync agent docs](https://github.com/animovement/.github/actions/workflows/sync-agent-docs.yml).")" >/dev/null
  echo "pull request opened"
else
  echo "existing pull request updated"
fi
