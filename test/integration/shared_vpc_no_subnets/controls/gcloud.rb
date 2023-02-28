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

group_email                 = attribute('group_email')
project_id                  = attribute('project_id')
project_number              = attribute('project_number')
service_account_email       = attribute('service_account_email')
shared_vpc                  = attribute('shared_vpc')

control 'project-factory-shared-vpc' do
  title "Project Factory shared VPC"

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
        JSON.parse(subject.stdout, symbolize_names: true)[:bindings]
      else
        []
      end
    end

    describe "roles/compute.networkAdmin" do
      it "includes the Datastream service account in the roles/compute.networkAdmin IAM binding" do
        expect(bindings).to include(
          members: including(
            "serviceAccount:service-#{project_number}@gcp-sa-datastream.iam.gserviceaccount.com"
          ),
          role: "roles/compute.networkAdmin",
        )
      end
    end

    describe "roles/compute.networkUser" do
      it "includes the project service account in the roles/compute.networkUser IAM binding" do
        expect(bindings).to include(
          members: including("serviceAccount:#{service_account_email}"),
          role: "roles/compute.networkUser",
        )
      end

      it "includes the group email in the roles/compute.networkUser IAM binding" do
        expect(bindings).to include(
          members: including("group:#{group_email}"),
          role: "roles/compute.networkUser",
        )
      end

      it "includes the GKE service account in the roles/compute.networkUser IAM binding" do
        expect(bindings).to include(
          members: including(
            "serviceAccount:service-#{project_number}@container-engine-robot.iam.gserviceaccount.com"
          ),
          role: "roles/compute.networkUser",
        )
      end

      it "includes the Dataflow service account in the roles/compute.networkUser IAM binding" do
        expect(bindings).to include(
          members: including("serviceAccount:service-#{project_number}@dataflow-service-producer-prod.iam.gserviceaccount.com"
          ),
          role: "roles/compute.networkUser",
        )
      end
    end
  end
end
