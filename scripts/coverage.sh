#!/usr/bin/env bash

set -o pipefail

DIR="${1}"
cd ${DIR}
dart pub global activate coverage
dart run coverage:test_with_coverage --port=9292
format_coverage --lcov --in=coverage --out=coverage.lcov --report-on=lib

