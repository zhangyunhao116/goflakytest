#!/usr/bin/env bash
set -e

WORK_DIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/workspace"
COMPILE_OPTS="$*"

git submodule init
git submodule sync --recursive
git submodule update

# Simple tests.
declare -a repos=(
    # {REPO_NAME} {EXTRA_COMPILE_OPTS}
    "fastcache" ""
    "fasthttp" "-race"
    "hcl" "-race"
    "gopkg" "-race"
    "skipmap" "-race"
    "skipset" "-race"
    "umap" ""
)

for ((i=0; i<${#repos[@]}; i+=2)); do
  REPO_NAME="${repos[i]}"
  EXTRA_COMPILE_OPTS="${repos[i+1]}"

  CMD="go test ${COMPILE_OPTS} ${EXTRA_COMPILE_OPTS} -failfast -count=1 ./..."
  echo \#\#\#\#\# TEST ${REPO_NAME} \#\#\#\#\# ${CMD}
  cd $WORK_DIR/$REPO_NAME && ${CMD} && echo $REPO_NAME PASSED!
done

# Complicated tests.

# k8s.
cd $WORK_DIR/kubernetes && env GOFLAGS="-count=1" make test && echo kubernetes PASSED!
