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

project_id                         = attribute('project_id')
project_number                     = attribute('project_number')
service_account_email              = attribute('service_account_email')
compute_service_account_email      = attribute('compute_service_account_email')
group_email                        = attribute('group_email')
group_name                         = attribute('group_name')
perimeter_name                     = attribute('perimeter_name')
policy_id                          = attribute('policy_id')

control 'project-factory-vpc-sc-project' do
	title 'Project Factory VPC service control perimeter project configuration'

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

	describe command("gcloud access-context-manager perimeters list --policy #{policy_id} --format=json") do
		its('exit_status') { should be 0 }
		its('stderr') { should eq '' }

		let(:all_perimeters) do
			if subject.exit_status == 0
				JSON.parse(subject.stdout)
			else
				{}
			end
		end
		describe "correct perimeter" do
			let(:perimeter) { all_perimeters.select { |p| p['title'] == perimeter_name }.first }
			it "exists" do
				expect(perimeter).to include(
					"description" =>  "New service perimeter",
					"name" => "accessPolicies/#{policy_id}/servicePerimeters/#{perimeter_name}",
					"status" => including(
						"resources" => match_array(["projects/#{project_number}"]),
						"restrictedServices" => match_array(["storage.googleapis.com"]),
					),
					"title" => perimeter_name,
				)
			end
		end
	end
end
