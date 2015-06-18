#!/bin/bash
#
# Pulls TeXLive binaries and install them in ~/.texlive
#
# This file is meant to live in the S3 bucket, and is accessible at:
# https://goo.gl/FR7t9V
#
set -e

my_url="https://goo.gl/FR7t9V"
base_url="https://heroku-buildpack-tex-mezis.s3.amazonaws.com"
platform=$(uname -m)-$(uname -s | tr A-Z a-z)

usage() {
  echo "Usage:"
  echo "  curl -skL ${my_url} | bash -s -- [-p {prefix}] [-v {version}] [-h]"
  echo
  echo "Options:"
  echo "  -h            Display this message and exit"
  echo "  -p {prefix}   Install to a given prefix (defaults to vendor/texlive)"
  echo "  -v {version}  Install a particular version (defaults to .texlive-version if present, or to maintainer's)"
  exit 0
}

while getopts "hp:v:" o ; do
  case "$o" in
    p)
      prefix=$OPTARG ;;
    v)
      version=$OPTARG ;;
    *)
      usage ;;
  esac
done

: ${prefix:=vendor/texlive}
bindir=${prefix}/bin/${platform}

if test "$version" = "" ; then
  if test -e .texlive-version ; then
    version=$(cat .texlive-version)
  else
    version=$(curl -skL ${base_url}/VERSION)
  fi
fi

full_url="${base_url}/texlive-${version}-${platform}.tar.gz"

echo "Fetching and installing TeX Live $version ;"
echo "Installing to $prefix"
test -e $prefix || mkdir -p $prefix
curl -kL -# $full_url | tar -C $prefix -zxf -

echo "Install complete."
echo "Don't forget to add ${bindir} to your PATH."
