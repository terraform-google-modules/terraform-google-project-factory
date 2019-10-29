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

# extract any --pip3_extra_flags from the incoming args, separating
# them to their own array, to be passed to pip3 prior to calling
# the precondition script.
PIP_FLAGS=()
REMAINING_FLAGS=()

function extract_pip_flags {
    local extract=0
    local flag_re='--.*'

    for flag do
        shift
        if [ "$flag" == "--pip3_extra_flags" ]; then
            extract=1
            continue
        elif [ $extract -eq 1 ]; then
            if ! [[ "$flag" =~ $flag_re ]]; then
                PIP_FLAGS+=("$flag")
            fi
        fi
        extract=0
        REMAINING_FLAGS+=("$flag")
    done
}

if command -v python3 1>/dev/null; then
    BASEDIR="$(dirname "$0")"

    extract_pip_flags "$@"

    if command -v pip3 1>/dev/null; then
        exec "pip3" "install" ${PIP_FLAGS[*]} "-r" "$BASEDIR/preconditions/requirements.txt"
    else
        echo "Unable to install project-factory requirements: pip3 executable not in PATH" 1>&2
    fi

    SCRIPT="$BASEDIR/preconditions/preconditions.py"
    exec "$SCRIPT" "${REMAINING_FLAGS[*]}"
else
    echo "Unable to check project-factory preconditions: python3 executable not in PATH" 1>&2
fi
