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

project_id = attribute('project_id', required: true, type: :string)
project_number = attribute('project_number', required: true, type: :string)
shared_vpc = attribute('shared_vpc', type: :string, default: ENV['TF_VAR_shared_vpc'])
group_email = attribute('group_email', default: nil)
service_account_email = attribute('service_account_email', required: true, type: :string)
extra_service_account_email = attribute('extra_service_account_email', required: true, type: :string)

control 'project-factory-shared-vpc' do
  title "Project Factory shared VPC"

  only_if { shared_vpc && !shared_vpc.empty? }

  describe command("gcloud compute shared-vpc get-host-project #{project_id} --format='get(name)'") do
    its('exit_status') { should eq 0 }
    its('stderr') { should eq '' }
    its('stdout.strip') { should eq shared_vpc }
  end

  describe command("gcloud projects get-iam-policy #{shared_vpc} --format=json") do
    its('exit_status') { should eq 0 }
    its('stderr') { should eq '' }

    let(:bindings) do
      if subject.exit_status == 0
        JSON.load(subject.stdout)['bindings']
      else
        []
      end
    end

    describe "roles/compute.networkUser" do
      let(:binding) do
        bindings.find { |b| b['role'] == 'roles/compute.networkUser' }
      end

      it "includes the project service account in the roles/compute.networkUser IAM binding" do
        binding["members"].should include "serviceAccount:#{service_account_email}"
      end

      it "includes the group email in the roles/compute.networkUser IAM binding" do
        if group_email.nil? || group_email.empty?
          pending "group email not defined"
        end

        binding["members"].should include "group:#{group_email}"
      end

      it "includes the GKE service account in the roles/compute.networkUser IAM binding" do
        binding["members"].should include "serviceAccount:service-#{project_number}@container-engine-robot.iam.gserviceaccount.com"
      end

      it "does not overwrite the membership of roles/compute.networkUser" do
        binding['members'].should include "serviceAccount:#{extra_service_account_email}"
      end
    end

    it "includes the GKE service account in the roles/container.hostServiceAgentUser IAM binding" do
      binding = bindings.find { |b| b['role'] == 'roles/container.hostServiceAgentUser' }
      binding.should_not be_nil

      binding["members"].should include "serviceAccount:service-#{project_number}@container-engine-robot.iam.gserviceaccount.com"
    end
  end
end
