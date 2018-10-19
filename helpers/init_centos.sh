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

# ####################################### #
#   VARIABLES FOR SETUP THE ENVIRONMENT   #
#    Please modify the variables below    #
#        according to your system         #
# ####################################### #

# Where almost all the downloads are performed
HOME="$HOME"

# GO resources path
GOHOME="/opt/go"
# GO source path
GOPATH="$GOHOME"
# GO bin path
GOBIN="$GOHOME/bin"
# GO version
GO_VERSION="1.9"
# Go installtion path
GO_INSTALL_PATH="/usr/local/"

# Arquitecture of your linux dist. (for terraform)
LINUXARQ="linux_amd64"

# Arquitecture of your linux dist. (for Go)
LINUXARQ_GO="linux-amd64"

# Terraform installation path
TERRAFORM_HOME="$HOME/terraform"
# Terraform version
TERRAFORM_VERSION="0.10.8"
# Terraform plugins path
TERRAFORM_PLUGINS_PATH="$HOME/.terraform.d/plugins"

# URL to bats repo
BATS_REPO="https://github.com/sstephenson/bats.git"
# Folder to install bats
BATS_HOME="/opt/bats"

# ####################################### #
#         Basic tool installation         #
# ####################################### #
sudo yum -y install wget
sudo yum -y install curl
sudo yum -y install git
sudo yum -y install unzip
sudo yum -y install epel-release
sudo yum -y install epel-release
sudo yum -y install jq
sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# ####################################### #
#         Terraform Installation          #
# ####################################### #
sudo mkdir -p "$TERRAFORM_HOME"
cd "$TERRAFORM_HOME" || exit

yes | sudo wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${LINUXARQ}.zip
yes | sudo unzip terraform_${TERRAFORM_VERSION}_${LINUXARQ}.zip*
sudo rm -f terraform_${TERRAFORM_VERSION}_${LINUXARQ}.zip*

export TERRAFORM_HOME=$TERRAFORM_HOME

# ####################################### #
#         GO Installation                 #
# ####################################### #
sudo mkdir -p $GOHOME
sudo rm -rf $GOHOME/
sudo mkdir -p $GOPATH
sudo mkdir -p $GOBIN
sudo mkdir -p $GO_INSTALL_PATH

cd $GOHOME || exit
sudo curl -LO "https://storage.googleapis.com/golang/go$GO_VERSION.$LINUXARQ_GO.tar.gz"
sudo tar -C $GO_INSTALL_PATH -xvzf "go$GO_VERSION.$LINUXARQ_GO.tar.gz"
sudo rm -rf go${GO_VERSION}.${LINUXARQ_GO}.tar.gz*

export GOPATH=$GOPATH
export GOBIN=$GOBIN

# ####################################### #
#      Environment variables setup        #
# ####################################### #

export PATH="$PATH:$TERRAFORM_HOME"
export PATH="$PATH:$GO_INSTALL_PATH/go/bin"

sudo touch /etc/profile.d/environment.sh
sudo chown "$(whoami)" /etc/profile.d/environment.sh
cat <<EOF | sudo tee -a /etc/profile.d/environment.sh > /dev/null
#!/bin/bash

export PATH="$PATH:$TERRAFORM_HOME:$GO_INSTALL_PATH/go/bin:/usr/local/bin"
export GOBIN=$GOBIN
export GOPATH=$GOPATH

EOF

# ####################################### #
#         PLUGINS INSTALLATION            #
# ####################################### #

# ####################################### #
#  Install the terraform-provider-gsuite  #
# ####################################### #
# Download and install dep

curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sudo PATH="$PATH" GOBIN="$GOBIN" sh
# Set PATH
export PATH="$PATH:/opt/go/bin"

sudo mkdir -p $GOPATH/src/github.com/DeviaVir/
cd $GOPATH/src/github.com/DeviaVir/ || exit

sudo git clone https://github.com/DeviaVir/terraform-provider-gsuite.git
cd terraform-provider-gsuite || exit

sudo GOPATH="$GOPATH" GOBIN="$GOBIN" PATH="$PATH:$GOBIN:/usr/local/go/bin" $GOBIN/dep ensure

sudo rm -rf $GOPATH/src/github.com/DeviaVir/terraform-provider-gsuite/vendor/github.com/DeviaVir/terraform-provider-gsuite

# Do not run the cmd below with sudo, or the module is installed under ~root/.terraform.d, instead of ~/.terraform.d
#GOPATH="$GOPATH" PATH="$PATH:$GOBIN:/usr/local/go/bin" GOBIN="$GOBIN" make dev
PATH="$PATH:$GOBIN:/usr/local/go/bin" make dev

# ####################################### #
#  Install the terraform-provider-google  #
# ####################################### #

sudo mkdir -p $GOPATH/src/github.com/terraform-providers
cd $GOPATH/src/github.com/terraform-providers || exit

sudo git clone https://github.com/terraform-providers/terraform-provider-google.git
cd terraform-provider-google || exit
# Compile it
sudo GOPATH="$GOPATH" GOBIN="$GOBIN" PATH="$PATH:/usr/local/go/bin" make fmt build

# Install it
mkdir -p "$TERRAFORM_PLUGINS_PATH"
cp -f $GOBIN/terraform-provider-google "$TERRAFORM_PLUGINS_PATH"

# ####################################### #
#        Google SDK Installation          #
# ####################################### #

sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-sdk]
name=Google Cloud SDK
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM

sudo yum -y install google-cloud-sdk

# ####################################### #
#        Python configuration             #
# ####################################### #
sudo yum install -y python34
sudo yum install -y python34-setuptools
sudo yum install -y python34-pip
sudo pip3 install --upgrade google-api-python-client

# ####################################### #
#        Bats  installation               #
# ####################################### #

sudo rm -rf $BATS_HOME/*
sudo mkdir -p $BATS_HOME
cd $BATS_HOME || exit
sudo git clone $BATS_REPO
cd bats/ || exit
sudo ./install.sh /usr/local

export PATH="$PATH:/usr/local/bin"

# ####################################### #
#                   INFO                  #
# ####################################### #

echo "Terraform installed on $TERRAFORM_HOME/"
echo "GO installed on $GO_INSTALL_PATH/bin/"
echo "GO sources installed on $GOPATH/src"
echo "GO binaries installed on $GOBIN"
echo "Terraform plugins installed on $TERRAFORM_PLUGINS_PATH"
echo "Terraform version: $(terraform -version)"
echo "Go version: $(go version)"
echo "Python3 version: $(python3 --version)"
echo "pip3 version: $(pip3 --version)"
echo "Bats version: $(bats --version)"
echo "Terraform plugins: $(ls -l "$HOME/.terraform.d/plugins")"
echo "gcloud version: $(gcloud version)"
