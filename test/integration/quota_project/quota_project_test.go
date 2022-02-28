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
	"context"
	"fmt"
	"io"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"

	"golang.org/x/oauth2/google"
)

func TestQuotaProject(t *testing.T) {
	quotaProjectT := tft.NewTFBlueprintTest(t)

	quotaProjectT.DefineVerify(func(assert *assert.Assertions) {
		quotaProjectT.DefaultVerify(assert)

		projectID := quotaProjectT.GetStringOutput("project_id")

		apis := gcloud.Run(t, fmt.Sprintf("services list --project %s", projectID))
		assert.Equal("ENABLED", apis.Get("#(config.name==\"serviceconsumermanagement.googleapis.com\").state").String(), "Service Consumer Management API is enabled")

		// Use Service Consumer Management API to get consumer quota
		ctx := context.Background()
		httpClient, _ := google.DefaultClient(ctx, "https://www.googleapis.com/auth/cloud-platform")
		resp, _ := httpClient.Get(fmt.Sprintf("https://serviceconsumermanagement.googleapis.com/v1beta1/services/compute.googleapis.com/projects/%s/consumerQuotaMetrics", projectID))
		defer resp.Body.Close()
		body, _ := io.ReadAll(resp.Body)
		assert.Equal("test", string(body), "has correct consumer quota override")
	})
	quotaProjectT.Test()
}
