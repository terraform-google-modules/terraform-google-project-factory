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

project_id                      = attribute('project_id')
service_account_email           = attribute('service_account_email')
compute_service_account_email   = attribute('compute_service_account_email')
container_service_account_email = attribute('container_service_account_email')
group_email                     = attribute('group_email')
group_name                      = attribute('group_name')

control 'project-factory-minimal' do
  title 'Project Factory minimal configuration'

  describe command("gcloud projects describe #{project_id} --format=json") do
    its('exit_status') { should be 0 }
    its('stderr') { should eq '' }

    let(:metadata) do
      if subject.exit_status == 0
        JSON.parse(subject.stdout, symbolize_names: true)
      else
        {}
      end
    end

    it { expect(metadata).to include(name: project_id[0...-5]) }
    it { expect(metadata).to include(projectId: project_id) }
  end

  describe command("gcloud services list --project #{project_id}") do
    its('exit_status') { should be 0 }
    its('stderr') { should eq '' }

    its('stdout') { should match(/compute\.googleapis\.com/) }
    its('stdout') { should match(/container\.googleapis\.com/) }
  end

  describe command("gcloud iam service-accounts list --project #{project_id} --format='json(email,disabled)'") do
    its('exit_status') { should be 0 }
    its('stderr') { should eq '' }

    let(:service_accounts) do
      if subject.exit_status == 0
        Hash[JSON.parse(subject.stdout, symbolize_names: true).map { |entry| [entry[:email], entry[:disabled]] }]
      else
        {}
      end
    end

    it { expect(service_accounts).to include service_account_email => false }
    it { expect(service_accounts).to include compute_service_account_email => true }
  end

  describe command("gcloud alpha resource-manager liens list --project #{project_id} --format=json") do
    its('exit_status') { should be 0 }
    its('stderr') { should eq '' }

    let(:liens) do
      if subject.exit_status == 0
        JSON.parse(subject.stdout, symbolize_names: true)
      else
        []
      end
    end

    it "has no liens" do
      expect(liens).to be_empty
    end
  end

  describe "group_email" do
    it "group_name should be empty" do
      expect(group_name).to be_empty
    end
    it "should be empty when group_name is empty" do
      expect(group_email).to be_empty
    end
  end

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

    it "container.developer role has been given to #{container_service_account_email}" do
      expect(bindings).to include(
        members: including("serviceAccount:#{container_service_account_email}"),
        role: "roles/container.developer",
      )
    end
  end
end
