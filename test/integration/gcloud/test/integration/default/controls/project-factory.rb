# encoding: utf-8

outputs = terraform_outputs()
project_id = outputs.project_info_example

control 'project-services' do
  title 'Project services activated by the project factory'

  describe google_project_services(project: project_id) do
    it { should exist }
    its('services') { should include "compute.googleapis.com" }
    its('services') { should include "appengine.googleapis.com" }
  end
end

control 'service-accounts' do
  title 'Service accounts created and managed by the project factory'

  describe google_service_accounts(project: project_id) do
    its('emails') { should include "project-service-account@#{project_id}.iam.gserviceaccount.com" }
    its('emails') { should include "#{project_id}@appspot.gserviceaccount.com" }
  end
end

control 'shared-vpc' do
  title 'Access to a shared VPC host project and associated subnets'

  only_if { ENV['SHARED_VPC'] }

  describe command("gcloud compute shared-vpc get-host-project #{project_id} --format='get(name)'") do
    its('exit_status') { should eq 0 }
    its('stdout.strip') { should eq ENV['SHARED_VPC'] }
  end

  describe google_project_iam_binding(
    project: ENV['SHARED_VPC'],
    role: 'roles/compute.networkUser'
  ) do
    it { should exist }
    its('members') { should include "serviceAccount:project-service-account@#{project_id}.iam.gserviceaccount.com" }

    it {
      require 'pp'
      pp subject.binding
    }
  end
end

control 'gsuite-group-roles' do
  title "Roles granted to an optional G Suite group"

  only_if { ENV['GSUITE_GROUP'] }
end

control 'usage-bucket' do
  title "Usage report exporting"

  only_if { ENV['USAGE_BUCKET_NAME'] }
end
