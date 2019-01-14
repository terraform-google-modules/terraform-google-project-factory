#!/bin/bash
# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [ -n "$(git status --porcelain)" ]; then
  echo -e "\nError, repository dirty, please commit or stash your changes.\n"
  exit 1
fi

NEW_VERSION=$(grep '##' CHANGELOG.md | head -n 1 | cut -d' ' -f2)
NEW_RELEASE_NAME=v$NEW_VERSION
CURRENT_RELEASE_NAME=$(git describe --abbrev=0 --tags)

if [ "$NEW_RELEASE_NAME" == "$CURRENT_RELEASE_NAME" ]; then
  echo -e "\nLatest version already released.\n"
  echo -e "If this is not so, make sure CHANGELOG.md is updated as necessary.\n"
  exit 1
fi

echo -e "\nUpdating usage examples in README to use $NEW_RELEASE_NAME and commiting...\n"

sed -i.bak -e "s/$CURRENT_RELEASE_NAME/$NEW_RELEASE_NAME/g" README.md && rm README.md.bak

git checkout master && \
  git add README.md && \
  git commit -m "Update usage examples in README to use $NEW_RELEASE_NAME." > /dev/null 2>&1

echo -e "Releasing $NEW_RELEASE_NAME...\n"

git tag -a "$NEW_RELEASE_NAME" -m "$NEW_RELEASE_NAME" && \
  git push origin master --verbose && \
  git push origin "$NEW_RELEASE_NAME" --verbose
