#!/usr/bin/env bash

set -e
set -o pipefail

# Validate the configurations.
curl --data-binary @codecov.yml https://codecov.io/validate

DIR="${1}"
cd "${DIR}" || exit

dart pub global activate coverage
dart run coverage:test_with_coverage --port=9292
format_coverage --lcov --in=coverage --out=coverage.lcov --report-on=lib
