#!/usr/bin/env bash

set -e

QGIS_VERSION=$1

# https://stackoverflow.com/questions/16989598/bash-comparing-version-numbers
function version_gt() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; }
if version_gt '4.19.7' $(sip -V); then
     echo "Your version of SIP is too old. SIP 4.19.7+ is required"
     exit 1
fi

echo "Current dir: $(pwd)"


echo "*** Create publish directory"
mkdir -p "publish"
rm -rf publish/*
pushd publish

OUTPUT=${QGIS_VERSION}

echo "*** Clone gh-pages branch"
if [[ $TRAVIS =~ true ]]; then
  git config --global user.email "qgisninja@gmail.com"
  git config --global user.name "Geo-Ninja"
  git clone https://${GH_TOKEN}@github.com/qgis/QGISPythonAPIDocumentation.git --depth 1 --branch gh-pages
  # temp output to avoid overwriting
  OUTPUT=${OUTPUT}_temp
else
  git clone git@github.com:qgis/QGISPythonAPIDocumentation.git --depth 1 --branch gh-pages
fi
pushd QGISPythonAPIDocumentation
rm -rf ${OUTPUT}
mkdir "${OUTPUT}"
cp -R ../../build/${QGIS_VERSION}/html/* ${OUTPUT}/

echo "travis_fold:start:gitcommit"
echo "*** Add and push"
git add --all
git commit -m "Update docs for QGIS ${QGIS_VERSION}"
echo "travis_fold:end:gitcommit"
if [[ $TRAVIS =~ true ]]; then
  echo "pushing from Travis"
  git push -v
else
  read -p "Are you sure to push? (y/n)" -n 1 -r response
  echo    # (optional) move to a new line
  if [[ $response =~ ^[Yy](es)?$ ]]; then
      git push
  fi
  rm -rf publish/*
fi

popd
popd
