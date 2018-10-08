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
domain = attribute('domain', required: true, type: :string)
region = attribute('region', type: :string, default: ENV['TF_VAR_region'])
app_engine_enabled = attribute('app_engine_enabled', default: nil)

control 'project-factory-app-engine' do
  title "Project Factory App Engine configuration"

  only_if { app_engine_enabled == "true" }

  describe command("gcloud app describe --project #{project_id} --format=json") do
    its('exit_status') { should be 0 }
    its('stderr') { should eq '' }

    let(:metadata) do
      if subject.exit_status == 0
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    it "uses the auth domain associated with the project-factory domain" do
      metadata["authDomain"].should eq domain
    end

    it "has no feature settings" do
      metadata["featureSettings"].should be_empty
    end

    it "is associated with the correct project id" do
      metadata["id"].should eq project_id
    end

    it "has the correct name" do
      metadata["name"].should eq "apps/#{project_id}"
    end

    it "is in the correct region" do
      metadata["locationId"].should eq region
    end

    it "is serving" do
      metadata["servingStatus"].should eq 'SERVING'
    end
  end
end
