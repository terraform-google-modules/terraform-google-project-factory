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

REPO_VER=v`cat CHANGELOG.md | grep "##" | head -n 1 | cut -d" " -f2`
CUR_GIT_TAG=`git describe --abbrev=0 --tags`
INGIT=false

echo "Current CHANGELOG version:" $REPO_VER
echo "Latest tag in Git:" $CUR_GIT_TAG

for i in `git tag --list`
do
  if [ "$i" == "$REPO_VER" ]
    then
      INGIT=true
      echo "Current tag of $REPO_VER exists in git."
  fi
done

if [ "$INGIT" == "false" ]
  then
    git tag -a $REPO_VER -m "$REPO_VER"
    echo "Updating README.md Usage Ref"
    sed -i '' "s/ref=v[0-9]\.[0-9]\.[0-9]/ref=$REPO_VER/g" README.md
fi
