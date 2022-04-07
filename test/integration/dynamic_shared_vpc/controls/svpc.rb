# Copyright 2020 Google LLC
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

service_project_id          = attribute('service_project_id')
service_project_ids         = attribute('service_project_ids')
service_project_number      = attribute('service_project_number')
service_project_b_number    = attribute('service_project_b_number')
service_project_c_number    = attribute('service_project_c_number')
service_account_email       = attribute('service_account_email')
shared_vpc                  = attribute('shared_vpc')
shared_vpc_subnet_name_01   = attribute('shared_vpc_subnet_name_01')
shared_vpc_subnet_region_01 = attribute('shared_vpc_subnet_region_01')
shared_vpc_subnet_name_02   = attribute('shared_vpc_subnet_name_02')
shared_vpc_subnet_region_02 = attribute('shared_vpc_subnet_region_02')

control 'svpc' do
  title "Project Factory shared VPC"

  service_project_ids.each do |project_id|
    describe command("gcloud compute shared-vpc get-host-project #{project_id} --format='get(name)'") do
      its('exit_status') { should eq 0 }
      its('stderr') { should eq '' }
      its('stdout.strip') { should eq shared_vpc }
    end
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


    it "service project with explicit subnets includes the GKE service account in the roles/container.hostServiceAgentUser IAM binding" do
      expect(bindings).to include(
        members: including("serviceAccount:service-#{service_project_number}@container-engine-robot.iam.gserviceaccount.com"),
        role: "roles/container.hostServiceAgentUser",
      )
    end

    it "service project b without explicit subnets includes the GKE service account in the roles/container.hostServiceAgentUser IAM binding" do
      expect(bindings).to include(
        members: including("serviceAccount:service-#{service_project_b_number}@container-engine-robot.iam.gserviceaccount.com"),
        role: "roles/container.hostServiceAgentUser",
      )
    end

      it "service project with explicit subnets does not include the GKE service account in the roles/compute.networkUser IAM binding" do
        expect(bindings).not_to include(
          members: including(
            "serviceAccount:service-#{service_project_number}@container-engine-robot.iam.gserviceaccount.com"
          ),
          role: "roles/compute.networkUser",
        )
      end

      it "service project c with explicit subnets and grant_network_role flag set to false does not include the GKE service account in the roles/compute.networkUser IAM binding" do
        expect(bindings).not_to include(
          members: including(
            "serviceAccount:service-#{service_project_c_number}@container-engine-robot.iam.gserviceaccount.com"
          ),
          role: "roles/compute.networkUser",
        )
      end
    end

    it "service project b without explicit subnets includes the GKE service account in the roles/compute.networkUser IAM binding" do
      expect(bindings).to include(
        members: including("serviceAccount:service-#{service_project_b_number}@container-engine-robot.iam.gserviceaccount.com"),
        role: "roles/compute.networkUser",
      )
    end

    it "service project c with explicit subnets and grant_network_role flag set to false does not include the GKE service account in the roles/compute.networkUser IAM binding" do
      expect(bindings).not_to include(
        members: including("serviceAccount:service-#{service_project_c_number}@container-engine-robot.iam.gserviceaccount.com"),
        role: "roles/compute.networkUser",
      )
    end

  it "service project b without explicit subnets includes the dataproc service account in the roles/compute.networkUser IAM binding" do
    expect(bindings).to include(
      members: including("serviceAccount:service-#{service_project_b_number}@dataproc-accounts.iam.gserviceaccount.com"),
      role: "roles/compute.networkUser",
    )
  end

  it "service project c with explicit subnets and grant_network_role flag set to false does not include the dataproc service account in the roles/compute.networkUser IAM binding" do
    expect(bindings).not_to include(
      members: including("serviceAccount:service-#{service_project_c_number}@dataproc-accounts.iam.gserviceaccount.com"),
      role: "roles/compute.networkUser",
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
      it "includes the project service account in the roles/compute.networkUser IAM binding" do
        expect(bindings).to include(
          members: including("serviceAccount:#{service_account_email}"),
          role: "roles/compute.networkUser",
        )
      end
    end

    describe "roles/compute.networkUser" do
      it "service project with explicit subnets includes the GKE service account in the roles/compute.networkUser IAM binding" do
        expect(bindings).to include(
          members: including("serviceAccount:service-#{service_project_number}@container-engine-robot.iam.gserviceaccount.com"),
          role: "roles/compute.networkUser",
        )
      end
    end

    describe "roles/compute.networkUser" do
      it "service project with explicit subnets includes project default service account in the roles/compute.networkUser IAM binding" do
        expect(bindings).to include(
          members: including("serviceAccount:project-service-account@#{service_project_ids[0]}.iam.gserviceaccount.com"),
          role: "roles/compute.networkUser",
        )
      end
    end

    describe "roles/compute.networkUser" do
      it "service project with explicit subnets includes the dataflow service account in the roles/compute.networkUser IAM binding" do
        expect(bindings).to include(
          members: including("serviceAccount:service-#{service_project_number}@dataflow-service-producer-prod.iam.gserviceaccount.com"
          ),
          role: "roles/compute.networkUser",
        )
      end
    end

    it "service project c with explicit subnets and grant_network_role flag set to false does not include project default service account in the roles/compute.networkUser IAM binding" do
      expect(bindings).not_to include(
        members: including(
          "serviceAccount:project-service-account@#{service_project_ids[2]}.iam.gserviceaccount.com"
        ),
        role: "roles/compute.networkUser",
      )
    end

    it "service project c with explicit subnets and grant_network_role flag set to false does not include the GCP Compute agent service account in the roles/compute.networkUser IAM binding" do
      expect(bindings).not_to include(
        members: including(
          "serviceAccount:#{service_project_c_number}@cloudservices.gserviceaccount.com"
        ),
        role: "roles/compute.networkUser",
      )
    end

    it "service project c with explicit subnets and grant_network_role flag set to false does not include the GCP Dataflow agent service account in the roles/compute.networkUser IAM binding" do
      expect(bindings).not_to include(
        members: including(
          "serviceAccount:service-#{service_project_c_number}@dataflow-service-producer-prod.iam.gserviceaccount.com"
        ),
        role: "roles/compute.networkUser",
      )
    end

    it "service project c with explicit subnets and grant_network_role flag set to false does not include the GCP Dataproc agent service account in the roles/compute.networkUser IAM binding" do
      expect(bindings).not_to include(
        members: including(
          "serviceAccount:service-#{service_project_c_number}@dataproc-accounts.iam.gserviceaccount.com"
        ),
        role: "roles/compute.networkUser",
      )
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
      it "includes the project service account in the roles/compute.networkUser IAM binding" do
        expect(bindings).to include(
          members: including("serviceAccount:#{service_account_email}"),
          role: "roles/compute.networkUser",
        )
      end
    end

    describe "roles/compute.networkUser" do
      it "service project b without explicit subnets does not include the GKE service account in the roles/compute.networkUser IAM binding" do
        expect(bindings).not_to include(
          members: including("serviceAccount:service-#{service_project_b_number}@container-engine-robot.iam.gserviceaccount.com"),
          role: "roles/compute.networkUser",
        )
      end
    end

  end
end
