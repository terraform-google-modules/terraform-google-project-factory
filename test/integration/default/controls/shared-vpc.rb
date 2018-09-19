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

outputs = terraform_outputs(dir: File.expand_path("../../../..", File.dirname(__FILE__)))

control 'project-factory-shared-vpc' do
  title "Project Factory shared VPC"

  only_if { !ENV.fetch('SHARED_VPC', '').empty? }

  describe command("gcloud compute shared-vpc get-host-project #{outputs.project_id} --format='get(name)'") do
    its('exit_status') { should eq 0 }
    its('stderr') { should eq '' }
    its('stdout.strip') { should eq ENV['SHARED_VPC'] }
  end

  describe command("gcloud projects get-iam-policy #{ENV['SHARED_VPC']} --format=json") do
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
        binding["members"].should include "serviceAccount:#{outputs.service_account_email}"
      end

      it "includes the group email in the roles/compute.networkUser IAM binding" do
        if outputs.group_email.nil? || outputs.group_email.empty?
          pending "group email not defined"
        end

        binding["members"].should include "group:#{outputs.group_email}"
      end

      it "includes the GKE service account in the roles/compute.networkUser IAM binding" do
        binding["members"].should include "serviceAccount:service-#{outputs.project_number}@container-engine-robot.iam.gserviceaccount.com"
      end

      it "does not overwrite the membership of roles/compute.networkUser" do
        binding['members'].should include "serviceAccount:#{outputs.extra_service_account_email}"
      end
    end

    it "includes the GKE service account in the roles/container.hostServiceAgentUser IAM binding" do
      binding = bindings.find { |b| b['role'] == 'roles/container.hostServiceAgentUser' }
      binding.should_not be_nil

      binding["members"].should include "serviceAccount:service-#{outputs.project_number}@container-engine-robot.iam.gserviceaccount.com"
    end
  end
end
