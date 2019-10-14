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

group_email = attribute('group_email')
shared_vpc  = attribute('shared_vpc')

control "gcp" do
  # The shared_vpc_no_subnets scenario is testing to ensure that
  # compute.networkUser bindings are set at the shared VPC host project level
  # and aren't set at the subnetwork level. The only way to be sure that
  # subnetwork bindings haven't been created (because a subnetwork was not
  # specified) is to loop through all subnetworks in all regions and ensure
  # there aren't any bindings set for the group being tested
  google_compute_regions(
    project: shared_vpc
  ).region_names.each do |region|
    google_compute_subnetworks(
      project: shared_vpc,
      region:  region,
    ).subnetwork_names.each do |subnetwork_name|
      describe "IAM bindings for subnetwork #{subnetwork_name} in region #{region}" do
        let(:bindings) do
          output = %x{gcloud beta compute networks subnets get-iam-policy #{subnetwork_name} --region #{region} --project #{shared_vpc} --format=json}
          JSON.parse(output, symbolize_names: true)[:bindings]
        end

        it "do not include #{group_email} in the roles/compute.networkUser IAM binding" do
          unless bindings.nil?
            expect(bindings).not_to include(
              members: including("group:#{group_email}"),
              role: "roles/compute.networkUser",
            )
          end
        end
      end
    end
  end
end

