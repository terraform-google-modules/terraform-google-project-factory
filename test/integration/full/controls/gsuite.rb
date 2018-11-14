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

extra_service_account_email = attribute('extra_service_account_email')
group_email                 = attribute('group_email')
group_role                  = attribute('group_role')
project_id                  = attribute('project_id')
service_account_email       = attribute('service_account_email')
credentials_path            = attribute('credentials_path')

ENV['CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE'] = File.absolute_path(
  credentials_path,
  File.join(__dir__, "../../../fixtures/full"))

control 'project-factory-gsuite' do
  title 'Project Factory G Suite integration'

  only_if { !(group_email.nil? || group_email == '') }

  describe command("gcloud projects get-iam-policy #{project_id} --format=json") do
    its('exit_status') { should eq 0 }
    its('stderr') { should eq '' }

    let(:bindings) do
      if subject.exit_status == 0
        JSON.parse(subject.stdout, symbolize_names: true)[:bindings]
      else
        []
      end
    end

    it "includes the group #{group_email.inspect} in role #{group_role.inspect}" do
      binding = bindings.find { |b| b[:role] == group_role }
      expect(binding).to_not be_nil
      expect(binding[:members]).to include("group:#{group_email}")
    end
  end

  describe command("gcloud iam service-accounts get-iam-policy #{service_account_email} --format=json") do
    its('exit_status') { should eq 0 }
    its('stderr') { should eq '' }

    let(:bindings) do
      if subject.exit_status == 0
        JSON.parse(subject.stdout, symbolize_names: true)[:bindings]
      else
        []
      end
    end

    it "includes gsuite group #{group_email.inspect} in the binding 'roles/iam.serviceAccountUser'" do
      binding = bindings.find { |b| b[:role] == 'roles/iam.serviceAccountUser' }
      expect(binding).to_not be_nil
      expect(binding[:members]).to include "group:#{group_email}"
    end

    it "does not overwrite the membership of role 'roles/iam.serviceAccountUser'" do
      binding = bindings.find { |b| b[:role] == 'roles/iam.serviceAccountUser' }
      expect(binding).to_not be_nil
      expect(binding[:members]).to include "serviceAccount:#{extra_service_account_email}"
    end
  end
end
