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

project_id = attribute('project_id')

control 'fabric-project' do
  title 'Submodule Project Fabric'

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

    it { expect(metadata).to include(name: project_id) }
    it { expect(metadata).to include(projectId: project_id) }
  end

  describe command("gcloud services list --project #{project_id}") do
    its('exit_status') { should be 0 }
    its('stderr') { should eq '' }

    its('stdout') { should match(/compute\.googleapis\.com/) }
    its('stdout') { should match(/storage-api\.googleapis\.com/) }
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

end
