#!/bin/bash

set -e

git ls-files -z -- '*.dart' | xargs -0 dart format "$@"