# Terraform Project Factory

Opinionated Google Cloud Platform project creation and configuration with Shared VPC, IAM, APIs, etc.

## Development

### Linting
The makefile in this project will lint or sometimes just format any shell,
Python, golang, Terraform, or Dockerfiles. The linters will only be run if
the makefile finds files with the appropriate file extension.

All of the linter checks are in the default make target, so you just have to
run

```
make -s
```

The -s is for 'silent'. Successful output looks like this

```
Running shellcheck
Running flake8
Running gofmt
Running terraform validate
Running hadolint on Dockerfiles
Test passed - Verified all file Apache 2 headers
```

The linters
are as follows:
* Shell - shellcheck. Can be found in homebrew
* Python - flake8. Can be installed with 'pip install flake8'
* Golang - gofmt. gofmt comes with the standard golang installation. golang
is a compiled language so there is no standard linter.
* Terraform - terraform has a built-in linter in the 'terraform validate'
command.
* Dockerfiles - hadolint. Can be found in homebrew
