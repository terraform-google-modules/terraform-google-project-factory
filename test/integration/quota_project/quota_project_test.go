// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package quota_project

import (
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

func TestQuotaProject(t *testing.T) {
	// const consumerQuota = [
	// 	{
	// 	  service    = "compute.googleapis.com"
	// 	  metric     = "SimulateMaintenanceEventGroup"
	// 	  dimensions = { region = "us-central1" }
	// 	  limit      = "%2F100s%2Fproject"
	// 	  value      = "19"
	// 	  }, {
	// 	  service    = "servicemanagement.googleapis.com"
	// 	  metric     = "servicemanagement.googleapis.com%2Fdefault_requests"
	// 	  dimensions = {}
	// 	  limit      = "%2Fmin%2Fproject"
	// 	  value      = "95"
	// 	}
	// ]
	quotaProjectT := tft.NewTFBlueprintTest(t)

	quotaProjectT.DefineVerify(func(assert *assert.Assertions) {
		quotaProjectT.DefaultVerify(assert)

		projectID := quotaProjectT.GetStringOutput("project_id")

		apis := gcloud.Run(t, fmt.Sprintf("services list --project %s", projectID))
		assert.Equal("ENABLED", apis.Get("#(config.name==\"servicemanagement.googleapis.com\").state").String(), "Service Management API is enabled")
	})
	quotaProjectT.Test()
}
