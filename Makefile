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

# Please note that this file was generated from [terraform-google-module-template](https://github.com/terraform-google-modules/terraform-google-module-template).
# Please make sure to contribute relevant changes upstream!

# Make will use bash instead of sh
SHELL := /usr/bin/env bash

# Docker build config variables
CREDENTIALS_PATH 			?= /cft/workdir/credentials.json
DOCKER_ORG 				:= gcr.io/cloud-foundation-cicd
DOCKER_TAG_BASE_KITCHEN_TERRAFORM 	?= 1.0.1
DOCKER_REPO_BASE_KITCHEN_TERRAFORM 	:= ${DOCKER_ORG}/cft/kitchen-terraform:${DOCKER_TAG_BASE_KITCHEN_TERRAFORM}

# All is the first target in the file so it will get picked up when you just run 'make' on its own
.PHONY: all
all: check generate_docs

# Run all available linters
.PHONY: check
check: check_shell check_python check_golang check_terraform check_docker check_base_files test_check_headers check_headers check_trailing_whitespace

# The .PHONY directive tells make that this isn't a real target and so
# the presence of a file named 'check_shell' won't cause this target to stop
# working
.PHONY: check_shell
check_shell:
	@source test/make.sh && check_shell

.PHONY: check_python
check_python:
	@source test/make.sh && check_python

.PHONY: check_golang
check_golang:
	@source test/make.sh && golang

.PHONY: check_terraform
check_terraform:
	@source test/make.sh && check_terraform

.PHONY: check_docker
check_docker:
	@source test/make.sh && docker

.PHONY: check_base_files
check_base_files:
	@source test/make.sh && basefiles

.PHONY: check_trailing_whitespace
check_trailing_whitespace:
	@source test/make.sh && check_trailing_whitespace

.PHONY: test_check_headers
test_check_headers:
	@echo "Testing the validity of the header check"
	@python test/test_verify_boilerplate.py

.PHONY: check_headers
check_headers:
	@source test/make.sh && check_headers

.PHONY: test_migrate
test_migrate:
	@echo "Testing migrate script"
	@python test/helpers/test_migrate.py

.PHONY: test_preconditions
test_preconditions:
	@echo "Testing preconditions script"
	@python test/scripts/preconditions/test_preconditions.py

# Unit tests
.PHONY: test_unit ## Run unit tests
test_unit: test_migrate test_preconditions

# Integration tests
.PHONY: test_integration
test_integration:
	test/ci_integration.sh

.PHONY: generate_docs
generate_docs:
	@source test/make.sh && generate_docs

.PHONY: release-new-version
release-new-version:
	@source helpers/release-new-version.sh

# Run docker
.PHONY: docker_run
docker_run:
	docker run --rm -it \
		-e BILLING_ACCOUNT_ID  \
		-e DOMAIN \
		-e FOLDER_ID \
		-e GROUP_NAME \
		-e ADMIN_ACCOUNT_EMAIL \
		-e ORG_ID \
		-e PROJECT_ID \
		-e SERVICE_ACCOUNT_JSON \
		-e GOOGLE_APPLICATION_CREDENTIALS=${CREDENTIALS_PATH} \
		-v $(CURDIR):/cft/workdir \
		${DOCKER_REPO_BASE_KITCHEN_TERRAFORM} \
		/bin/bash -c "source test/ci_integration.sh && setup_environment && exec /bin/bash"

.PHONY: docker_create
docker_create:
	docker run --rm -it \
		-e BILLING_ACCOUNT_ID  \
		-e DOMAIN \
		-e FOLDER_ID \
		-e GROUP_NAME \
		-e ADMIN_ACCOUNT_EMAIL \
		-e ORG_ID \
		-e PROJECT_ID \
		-e SERVICE_ACCOUNT_JSON \
		-e GOOGLE_APPLICATION_CREDENTIALS=${CREDENTIALS_PATH} \
		-v $(CURDIR):/cft/workdir \
		${DOCKER_REPO_BASE_KITCHEN_TERRAFORM} \
		/bin/bash -c "source test/ci_integration.sh && setup_environment && kitchen create"

.PHONY: docker_converge
docker_converge:
	docker run --rm -it \
		-e BILLING_ACCOUNT_ID  \
		-e DOMAIN \
		-e FOLDER_ID \
		-e GROUP_NAME \
		-e ADMIN_ACCOUNT_EMAIL \
		-e ORG_ID \
		-e PROJECT_ID \
		-e SERVICE_ACCOUNT_JSON \
		-e GOOGLE_APPLICATION_CREDENTIALS=${CREDENTIALS_PATH} \
		-v $(CURDIR):/cft/workdir \
		${DOCKER_REPO_BASE_KITCHEN_TERRAFORM} \
		/bin/bash -c "source test/ci_integration.sh && setup_environment && kitchen converge"

.PHONY: docker_verify
docker_verify:
	docker run --rm -it \
		-e BILLING_ACCOUNT_ID  \
		-e DOMAIN \
		-e FOLDER_ID \
		-e GROUP_NAME \
		-e ADMIN_ACCOUNT_EMAIL \
		-e ORG_ID \
		-e PROJECT_ID \
		-e SERVICE_ACCOUNT_JSON \
		-e GOOGLE_APPLICATION_CREDENTIALS=${CREDENTIALS_PATH} \
		-v $(CURDIR):/cft/workdir \
		${DOCKER_REPO_BASE_KITCHEN_TERRAFORM} \
		/bin/bash -c "source test/ci_integration.sh && setup_environment && kitchen verify"

.PHONY: docker_destroy
docker_destroy:
	docker run --rm -it \
		-e BILLING_ACCOUNT_ID  \
		-e DOMAIN \
		-e FOLDER_ID \
		-e GROUP_NAME \
		-e ADMIN_ACCOUNT_EMAIL \
		-e ORG_ID \
		-e PROJECT_ID \
		-e SERVICE_ACCOUNT_JSON \
		-e GOOGLE_APPLICATION_CREDENTIALS=${CREDENTIALS_PATH} \
		-v $(CURDIR):/cft/workdir \
		${DOCKER_REPO_BASE_KITCHEN_TERRAFORM} \
		/bin/bash -c "source test/ci_integration.sh && setup_environment && kitchen destroy"

.PHONY: test_integration_docker
test_integration_docker:
	docker run --rm -it \
		-e BILLING_ACCOUNT_ID  \
		-e DOMAIN \
		-e FOLDER_ID \
		-e GROUP_NAME \
		-e ADMIN_ACCOUNT_EMAIL \
		-e ORG_ID \
		-e PROJECT_ID \
		-e SERVICE_ACCOUNT_JSON \
		-e GOOGLE_APPLICATION_CREDENTIALS=${CREDENTIALS_PATH} \
		-v $(CURDIR):/cft/workdir \
		${DOCKER_REPO_BASE_KITCHEN_TERRAFORM} \
		make test_integration
