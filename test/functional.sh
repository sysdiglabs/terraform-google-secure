#!/usr/bin/env bash

set -e

test -n "${EXAMPLES}" || EXAMPLES=$(find examples -type f -name main.tf)

for example in ${EXAMPLES} ; do
  printf "Functional testing - ${example}\n"
  example_dir="$(dirname ${example})"
  test -d "${example_dir}" || (printf "not an example directory: ${example_dir}\n" ; exit 1)
  pushd "${example_dir}"
    # run
    terraform init
    terraform validate

    # cleanup (except configuration file)
    git clean -fxde main.tf
  popd
done
