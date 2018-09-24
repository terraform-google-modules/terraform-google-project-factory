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

control 'project-factory-gsuite' do
  title 'Project Factory G Suite integration'

  only_if { outputs.group_email }

  describe command("gcloud projects get-iam-policy #{outputs.project_id} --format=json") do
    its('exit_status') { should eq 0 }
    its('stderr') { should eq '' }

    let(:bindings) do
      if subject.exit_status == 0
        JSON.load(subject.stdout)['bindings']
      else
        []
      end
    end

    it "includes the gsuite group in the given role" do
      if !attribute('group_role')
        pending
      end

      binding = bindings.find { |b| b['role'] == attribute('group_role') }
      binding.should_not be_nil

      binding['members'].should include "group:#{outputs.group_email}"
    end
  end

  describe command("gcloud iam service-accounts get-iam-policy #{outputs.service_account_email} --format=json") do
    its('exit_status') { should eq 0 }
    its('stderr') { should eq '' }

    let(:bindings) do
      if subject.exit_status == 0
        JSON.load(subject.stdout)['bindings']
      else
        []
      end
    end

    it "includes the group email " do
      binding = bindings.find { |b| b['role'] == 'roles/iam.serviceAccountUser' }
      binding.should_not be_nil

      binding['members'].should include "group:#{outputs.group_email}"
    end

    it "does not overwrite the membership of role roles/iam.serviceAccountUser" do
      binding = bindings.find { |b| b['role'] == 'roles/iam.serviceAccountUser' }
      binding.should_not be_nil

      binding['members'].should include "serviceAccount:#{outputs.extra_service_account_email}"
    end
  end
end
