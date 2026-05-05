#!/usr/bin/env bash
set -euo pipefail

if [ "$HAS_APPROVED_LABEL" = "true" ]; then
  comment_id=$(gh api \
    "/repos/${GITHUB_REPOSITORY}/issues/${PR_NUMBER}/comments" \
    --jq '.[] | select(.user.login == "github-actions[bot]" and (.body | contains("Automated testing is pending maintainer approval"))) | .id' \
    | head -1)

  if [ -n "$comment_id" ]; then
    gh api --method DELETE \
      "/repos/${GITHUB_REPOSITORY}/issues/comments/$comment_id"
    new_body="Your PR has been reviewed by a maintainer and approved for automated testing"
  else
    new_body="Test Started"
  fi

  gh pr comment "$PR_NUMBER" \
    --repo "$GITHUB_REPOSITORY" \
    --body "$new_body"
else
  gh pr comment "$PR_NUMBER" \
    --repo "$GITHUB_REPOSITORY" \
    --body "Automated testing is pending maintainer approval"
fi
