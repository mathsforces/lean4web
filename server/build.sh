#!/usr/bin/env bash

SECONDS=0

# Operate in the directory where this file is located
cd $(dirname $0)

# Install lean
wget https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh
chmod +x elan-init.sh
./elan-init.sh -y --default-toolchain leanprover/lean4:nightly
source ~/.profile
lake --version

(cd LeanProject &&
  rm -f ./lake-manifest.json &&
  lake update && # download latest mathlib
  cp ./lake-packages/mathlib/lean-toolchain . && # copy lean version of mathlib
  lake exe cache get &&
  lake build)

# Build elan image if not already present
docker build --pull --rm -f lean.Dockerfile -t lean:latest .

# Copy info about new versions to the client.
./copy_versions.sh

duration=$SECONDS
echo "Finished in $(($duration / 60)):$(($duration % 60)) min."
echo "Finished in $(($duration / 60)):$(($duration % 60)) min." | logger -t lean4web
