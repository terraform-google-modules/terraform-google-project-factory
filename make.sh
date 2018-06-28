#!/bin/bash

function check_bash() {
  while IFS= read -r -d ''
  do
    # shellcheck disable=SC2154
    read -r firstline<"$i";
    if [[ "$firstline" != *"bash -e"* ]];
    then
      echo "$i is missing shebang with -e";
      exit 1;
    fi;
  done <   <(find . -name "*.sh")
}

function basefiles() {
  set -e
  echo "Checking for required files"
  test -f CODE-OF-CONDUCT.md || echo "Missing CODE-OF-CONDUCT.md"
  test -f CONTRIBUTING.md || echo "Missing CONTRIBUTING.md"
  test -f LICENSE || echo "Missing LICENSE"
  test -f README.md || echo "Missing README.md"
}

function docker() {
  set -e
  count=$(find . -name "Dockerfile" -print0 | wc -l)
  if [ "$count" != 0 ]; then
  echo "Running hadolint on Dockerfiles"
  find . -name "Dockerfile" -print0 | xargs hadolint
  fi
}

function check_terraform() {
  set -e
  count=$(find . -name "*.tf" | wc -l)
  if [ "$count" != 0 ]; then
  echo "Running terraform validate"
  while IFS= read -r -d ''
  do terraform validate --check-variables=false "$(dirname "$i")"
  done <   <(find . -name "*.tf")
  fi
}

function golang() {
  set -e
  count=$(find . -name "*.go" | wc -l)
  if [ "$count" != 0 ]; then
  echo "Running gofmt"
  gofmt -w .
  fi
}

function check_python() {
  set -e
  count=$(find . -name "*.py" | wc -l)
  if [ "$count" != 0 ]; then
  echo "Running flake8"
  flake8
  fi
}

function check_shell() {
  set -e
  count=$(find . -name "*.sh" | wc -l)
  if [ "$count" != 0 ]; then
  echo "Running shellcheck"
  find . -name "*.sh" -print0 | xargs shellcheck
  fi
}

function check_trailing_whitespace() {
  echo "The following lines have trailing whitespace"
  grep -r '[[:blank:]]$' .
  rc=$?
  if [ $rc = 0 ]; then
    exit 1
  fi
}