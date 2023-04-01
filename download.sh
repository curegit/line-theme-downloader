#!/bin/bash
set -u
# Command-line arguments
readonly id=${1:-}
readonly version=${2:-0}
# Definition of platforms to download
readonly platforms="ANDROID IOS"
# Format validation of a theme ID
function validateThemeIdFormat() {
  [[ "$1" =~ ^[-a-z0-9][-a-z0-9][-a-z0-9][-a-z0-9][-a-z0-9][-a-z0-9]+$ ]]
}
# Checks if it is able to get the URI content
function checkHttpResponseStatus() {
  curl -sfL "$1" > /dev/null 2>&1
}
# Outputs the URI of a small asset associated with the specified theme
function buildThemeEvidenceUri() {
  local subdir1=${1:0:2}
  local subdir2=${1:2:2}
  local subdir3=${1:4:2}
  local baseuri="http://dl.shop.line.naver.jp/themeshop/v1/products"
  printf "%s/%s/%s/%s/%s/%s/ANDROID/icon_86x123.png" "$baseuri" "$subdir1" "$subdir2" "$subdir3" "$1" "$2"
}
# Outputs the URI of the specified theme's zip
function buildThemeZipUri() {
  local subdir1=${1:0:2}
  local subdir2=${1:2:2}
  local subdir3=${1:4:2}
  local baseuri="http://dl.shop.line.naver.jp/themeshop/v1/products"
  printf "%s/%s/%s/%s/%s/%s/%s/theme.zip" "$baseuri" "$subdir1" "$subdir2" "$subdir3" "$1" "$2" "$3"
}
# Whether the URI content as a evidence of the theme existence exists
function checkThemeExistence() {
  checkHttpResponseStatus "$(buildThemeEvidenceUri "$1" "${2:-1}")"
}
# Outputs a filename to save a theme zip
function buildThemeZipFilename() {
  printf "Theme-%s-%s-%s.zip" "$1" "$2" "$3"
}
# Downloads the zip of the specified theme and returns the path saved to
function downloadThemeZip() {
  local uri path
  uri="$(buildThemeZipUri "$1" "$2" "$3")"
  path="$(buildThemeZipFilename "$1" "$2" "$3")"
  curl -sfSL -o "$path" "$uri" || exit
  printf "%s" "$path"
}
# Show help
if [ $# = 0 ]; then
  echo "* Usage *"
  echo "$0 [ID [VERSION]]"
  echo
  exit 0
fi
# Verify the command-line arguments
if [[ ! "$version" =~ ^-?(0|[1-9][0-9]*)$ ]]; then
  echo "Package version must be an integer" 1>&2
  exit 1
fi
if [ "$version" -lt -1 ]; then
  echo "Package version parameter out of range" 1>&2
  exit 1
fi
if ! validateThemeIdFormat "$id"; then
  echo "Invalid package ID format" 1>&2
  exit 1
fi
# Check the specified theme exists
if [ "$version" -lt 1 ]; then
  if ! checkThemeExistence "$id"; then
    echo "No such theme package (possibly network error)" 1>&2
    exit 1
  fi
  echo "Verified: $id"
else
  if ! checkThemeExistence "$id" "$version"; then
    echo "No such theme package or specified version (possibly network error)" 1>&2
    exit 1
  fi
  echo "Verified: $id (version $version)"
fi
# Downloading process
if [ "$version" = -1 ]; then
  # Download the all versions
  for ((i=1; ; i++)); do
    if ! checkThemeExistence "$id" "$i"; then
      break
    fi
    echo "Downloading: $id (version $i)"
    for platform in $platforms; do
      dest="$(downloadThemeZip "$id" "$i" "$platform")"
      echo "Saved: $dest ($platform)"
    done
  done
elif [ "$version" = 0 ]; then
  # Download the latest version
  latest=1
  for ((i=2; ; i++)); do
    if ! checkThemeExistence "$id" "$i"; then
      break
    else
      echo "Skipped: $id (version $latest)"
      latest="$i"
    fi
  done
  echo "Downloading: $id (version $latest)"
  for platform in $platforms; do
    dest="$(downloadThemeZip "$id" "$latest" "$platform")"
    echo "Saved: $dest ($platform)"
  done
else
  # Download the specified version
  echo "Downloading: $id (version $version)"
  for platform in $platforms; do
    dest="$(downloadThemeZip "$id" "$version" "$platform")"
    echo "Saved: $dest ($platform)"
  done
fi
