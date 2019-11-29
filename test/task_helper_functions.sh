# Prepare the setup environment
prepare_environment() {
  set -eu

  init_credentials_if_found

  echo "Create gsuite serice account key"
  gcloud iam service-accounts keys create ./test/setup/gcloud.json --iam-account=ci-gsuite-sa@ci-gsuite-sa-project.iam.gserviceaccount.com
  echo "Done trying to create gsuite sa key"

  cd test/setup/ || exit
  terraform init
  terraform apply -auto-approve

  if [ -f make_source.sh ]; then
    echo "Found test/setup/make_source.sh. Using it for additional explicit environment configuration."
    ./make_source.sh
  fi
}
