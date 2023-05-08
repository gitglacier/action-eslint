#!/bin/bash

echo "## Starting run"
cd "${GITHUB_WORKSPACE}"

export NODE_PATH=$(npm root -g)
export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"
ESLINT_FORMATTER="${GITHUB_ACTION_PATH}/eslint-formatter-rdjson/index.js"
ESLINT_CONFIG="${GITHUB_ACTION_PATH}/.eslintrc.js"

echo "## reviewdog --version"
reviewdog --version
echo "## eslint --version"
eslint --version

FILES=$(git diff --diff-filter=ACM --name-only origin/master | grep -P "(\.js)$")

reviewdog_rc=0
if [[ ${#FILES[@]} -gt 0 ]]; then
   echo "## Running eslint"
   eslint --quiet -c="${ESLINT_CONFIG}" -f="${ESLINT_FORMATTER}" "$FILES" \
     | reviewdog -f=rdjson \
         -name="javascript-syntax" \
         -reporter="github-pr-check" \
         -filter-mode="file" \
         -fail-on-error="true" \
         -level="error"

   reviewdog_rc=$?
else
   echo "## Not running eslint, no files to check"
fi


exit $reviewdog_rc
