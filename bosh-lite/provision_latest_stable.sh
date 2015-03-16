#!/usr/bin/env bash

set -xe

DIR="$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)"
STEMCELL_SOURCE=https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent
STEMCELL_FILE=latest-bosh-stemcell-warden.tgz
CF_DIR="$DIR/.."

main() {
  fetch_stemcell
  upload_stemcell
  build_manifest
  deploy_release
}

fetch_stemcell() {
  if [[ ! -e $STEMCELL_FILE ]]
  then
    curl -L --progress-bar "${STEMCELL_SOURCE}" -o "$STEMCELL_FILE"
  fi
}

upload_stemcell() {
  bosh -n -u admin -p admin upload stemcell --skip-if-exists $STEMCELL_FILE
}

build_manifest() {
    $DIR/make_manifest
}

deploy_release() {
  MOST_RECENT_CF_RELEASE=$(find ${CF_DIR}/releases -regex ".*cf-[0-9]*.yml" | sort | tail -n 1)
  bosh -n -u admin -p admin upload release --skip-if-exists $MOST_RECENT_CF_RELEASE
  bosh -n -u admin -p admin deploy
}

main
