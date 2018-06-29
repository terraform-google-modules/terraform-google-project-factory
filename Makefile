# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

SHELL := /bin/bash

all: check_shell check_python check_golang check_terraform check_docker check_base_files check_headers

.PHONY: check_shell
check_shell:
	source make.sh && check_shell

.PHONY: check_python
check_python:
	source make.sh && check_python

.PHONY: check_golang
check_golang:
	source make.sh && golang

.PHONY: check_terraform
check_terraform:
	source make.sh && check_terraform

.PHONY: check_docker
check_docker:
	source make.sh && docker

.PHONY: check_base_files
check_base_files:
	source make.sh && basefiles

.PHONY: check_shebangs
check_shebangs:
	source make.sh && check_bash

.PHONY: check_trailing_whitespace
check_trailing_whitespace:
	source make.sh && check_trailing_whitespace

.PHONY: check_headers
check_headers:
	echo "Checking file headers"
	python test/verify_boilerplate.py

