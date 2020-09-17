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
project_id                  = attribute('project_id')
project_number              = attribute('project_number')
service_account_email       = attribute('service_account_email')
shared_vpc                  = attribute('shared_vpc')
shared_vpc_subnet_name_01   = attribute('shared_vpc_subnet_name_01')
shared_vpc_subnet_region_01 = attribute('shared_vpc_subnet_region_01')
shared_vpc_subnet_name_02   = attribute('shared_vpc_subnet_name_02')
shared_vpc_subnet_region_02 = attribute('shared_vpc_subnet_region_02')

control 'project-factory-shared-vpc' do
  title "Project Factory shared VPC"

  only_if { !(shared_vpc.nil? || shared_vpc == '') }

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

    describe "roles/compute.networkUser" do
      it "does not include the project service account in the roles/compute.networkUser IAM binding" do
        expect(bindings).not_to include(
          members: including("serviceAccount:#{service_account_email}"),
          role: "roles/compute.networkUser",
        )
      end

      it "does not include the group email in the roles/compute.networkUser IAM binding" do
        if group_email.nil? || group_email.empty?
          pending "group_email not defined - skipping test"
        end

        expect(bindings).not_to include(
          members: including("group:#{group_email}"),
          role: "roles/compute.networkUser",
        )
      end

      it "does not include the GKE service account in the roles/compute.networkUser IAM binding" do
        expect(bindings).not_to include(
          members: including(
            "serviceAccount:service-#{project_number}@container-engine-robot.iam.gserviceaccount.com"
          ),
          role: "roles/compute.networkUser",
        )
      end

      it "does not include the dataflow service account in the roles/compute.networkUser IAM binding" do
        expect(bindings).not_to include(
          members: including("serviceAccount:service-#{project_number}@dataflow-service-producer-prod.iam.gserviceaccount.com"
          ),
          role: "roles/compute.networkUser",
        )
      end

      it "does not overwrite the membership of roles/compute.networkUser" do
        expect(bindings).to include(
          members: including("serviceAccount:#{extra_service_account_email}"),
          role: "roles/compute.networkUser",
        )
      end
    end

    it "includes the GKE service account in the roles/container.hostServiceAgentUser IAM binding" do
      expect(bindings).to include(
        members: including("serviceAccount:service-#{project_number}@container-engine-robot.iam.gserviceaccount.com"),
        role: "roles/container.hostServiceAgentUser",
      )
    end
  end

  describe command("gcloud beta compute networks subnets get-iam-policy #{shared_vpc_subnet_name_01} --region #{shared_vpc_subnet_region_01} --project #{shared_vpc} --format=json") do
    its('exit_status') { should eq 0 }
    its('stderr') { should eq '' }

    let(:bindings) do
      if subject.exit_status == 0
        JSON.parse(subject.stdout, symbolize_names: true)[:bindings]
      else
        []
      end
    end

    describe "roles/compute.networkUser" do
      it "includes the group email in the roles/compute.networkUser IAM binding" do
        if group_email.nil? || group_email.empty?
          pending "group_email not defined - skipping test"
        end

        expect(bindings).to include(
          members: including("group:#{group_email}"),
          role: "roles/compute.networkUser",
        )
      end
    end
  end

  describe command("gcloud beta compute networks subnets get-iam-policy #{shared_vpc_subnet_name_02} --region #{shared_vpc_subnet_region_02} --project #{shared_vpc} --format=json") do
    its('exit_status') { should eq 0 }
    its('stderr') { should eq '' }

    let(:bindings) do
      if subject.exit_status == 0
        JSON.parse(subject.stdout, symbolize_names: true)[:bindings]
      else
        []
      end
    end

    describe "roles/compute.networkUser" do
      it "includes the group email in the roles/compute.networkUser IAM binding" do
        if group_email.nil? || group_email.empty?
          pending "group_email not defined - skipping test"
        end

        expect(bindings).to include(
          members: including("group:#{group_email}"),
          role: "roles/compute.networkUser",
        )
      end
    end
  end
end
