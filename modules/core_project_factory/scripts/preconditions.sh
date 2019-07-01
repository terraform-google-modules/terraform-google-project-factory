#!/bin/sh

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

if command -v python3 1>/dev/null; then
    BASEDIR="$(dirname "$0")"

    if command -v pip3 1>/dev/null; then
        exec "pip3" "install" "-r" "$BASEDIR/preconditions/requirements.txt"
    else
        echo "Unable to install project-factory requirements: pip3 executable not in PATH" 1>&2
    fi

    SCRIPT="$BASEDIR/preconditions/preconditions.py"
    exec "$SCRIPT" "$@"
else
    echo "Unable to check project-factory preconditions: python3 executable not in PATH" 1>&2
fi
