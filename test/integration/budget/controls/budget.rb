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

project_id                    = attribute("project_id")
billing_account               = attribute("billing_account")
parent_project_id             = attribute("parent_project_id")
pubsub_topic                  = attribute("pubsub_topic")
main_budget_name              = attribute("main_budget_name")
additional_budget_name        = attribute("additional_budget_name")
budget_amount                 = attribute("budget_amount")
budget_alert_spent_percents   = attribute("budget_alert_spent_percents")
budget_services               = attribute("budget_services")
budget_credit_types_treatment = attribute("budget_credit_types_treatment")

control "project-factory-budget-project" do
  title "Project Factory budget project"

  describe command("gcloud projects describe #{project_id} --format=json") do
    its("exit_status") { should be 0 }
    its("stderr") { should eq "" }

    let(:metadata) do
      if subject.exit_status == 0
        JSON.parse(subject.stdout, symbolize_names: true)
      else
        {}
      end
    end

    it { expect(metadata).to include(name: project_id[0...-7]) }
    it { expect(metadata).to include(projectId: project_id) }
  end
end

control "project-factory-budget-main" do
  title "Main Budget"

  describe command("gcloud alpha billing budgets describe #{main_budget_name} --billing-account=#{billing_account} --format=json") do
    its("exit_status") { should be 0 }
    its("stderr") { should eq "" }

    let(:metadata) do
      if subject.exit_status == 0
        JSON.parse(subject.stdout, symbolize_names: true)
      else
        {}
      end
    end

    it "has expected structure" do
      expect(metadata).to match(hash_including({
        name: "billingAccounts/#{billing_account}/budgets/#{main_budget_name}",
        displayName: "Budget For #{project_id}",
        budgetFilter: hash_including({creditTypesTreatment: "INCLUDE_ALL_CREDITS"}),
        amount: hash_including({specifiedAmount: hash_including({units: "#{budget_amount}"})}),
      }))

      expect(metadata[:budgetFilter][:projects].length).to be(1)
      expect(metadata[:thresholdRules]).to include({spendBasis:"CURRENT_SPEND", thresholdPercent:0.5})
      expect(metadata[:thresholdRules]).to include({spendBasis:"CURRENT_SPEND", thresholdPercent:0.7})
      expect(metadata[:thresholdRules]).to include({spendBasis:"CURRENT_SPEND", thresholdPercent:1})
    end

  end
end

control "project-factory-budget-additional" do
  title "Additional Budget"

  describe command("gcloud alpha billing budgets describe #{additional_budget_name} --billing-account=#{billing_account} --format=json") do
    its("exit_status") { should be 0 }
    its("stderr") { should eq "" }

    let(:metadata) do
      if subject.exit_status == 0
        JSON.parse(subject.stdout, symbolize_names: true)
      else
        {}
      end
    end

    it "has expected structure" do
      expect(metadata).to match(hash_including({
        name: "billingAccounts/#{billing_account}/budgets/#{additional_budget_name}",
        displayName: "CI/CD Budget for #{project_id}",
        budgetFilter: hash_including({creditTypesTreatment: budget_credit_types_treatment}),
        amount: hash_including({specifiedAmount: hash_including({units: "#{budget_amount}"})}),
        allUpdatesRule: hash_including({pubsubTopic: "projects/#{project_id}/topics/#{pubsub_topic}"}),
      }))

      expect(metadata[:budgetFilter][:projects].length).to be(2)

      expect(metadata[:thresholdRules]).to include({spendBasis:"CURRENT_SPEND", thresholdPercent:0.7})
      expect(metadata[:thresholdRules]).to include({spendBasis:"CURRENT_SPEND", thresholdPercent:0.8})
      expect(metadata[:thresholdRules]).to include({spendBasis:"CURRENT_SPEND", thresholdPercent:0.9})
      expect(metadata[:thresholdRules]).to include({spendBasis:"CURRENT_SPEND", thresholdPercent:1})

      expect(metadata[:budgetFilter][:services].length).to be(budget_services.length)
      for service in budget_services
        expect(metadata[:budgetFilter][:services]).to include("services/#{service}")
      end
    end

  end
end
