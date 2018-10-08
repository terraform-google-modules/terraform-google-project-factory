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
group_email = attribute('group_email', default: nil)
group_role = attribute('group_role', default: nil)
service_account_email = attribute('service_account_email', required: true, type: :string)
extra_service_account_email = attribute('extra_service_account_email', required: true, type: :string)

control 'project-factory-gsuite' do
  title 'Project Factory G Suite integration'

  only_if { group_email && !group_email.empty? }

  describe command("gcloud projects get-iam-policy #{project_id} --format=json") do
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
      if !group_role
        pending
      end

      binding = bindings.find { |b| b['role'] == group_role }
      binding.should_not be_nil

      binding['members'].should include "group:#{group_email}"
    end
  end

  describe command("gcloud iam service-accounts get-iam-policy #{service_account_email} --format=json") do
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

      binding['members'].should include "group:#{group_email}"
    end

    it "does not overwrite the membership of role roles/iam.serviceAccountUser" do
      binding = bindings.find { |b| b['role'] == 'roles/iam.serviceAccountUser' }
      binding.should_not be_nil

      binding['members'].should include "serviceAccount:#{extra_service_account_email}"
    end
  end
end
