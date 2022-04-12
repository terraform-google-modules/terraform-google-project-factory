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
	"net/url"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
	"github.com/stretchr/testify/assert"
	"golang.org/x/oauth2/google"
)

func TestQuotaProject(t *testing.T) {
	quotaProjectT := tft.NewTFBlueprintTest(t)

	quotaProjectT.DefineVerify(func(assert *assert.Assertions) {
		quotaProjectT.DefaultVerify(assert)

		projectID := quotaProjectT.GetStringOutput("project_id")

		apis := gcloud.Runf(t, "services list --project %s", projectID)
		assert.Equal("ENABLED", apis.Get("#(config.name==\"serviceusage.googleapis.com\").state").String(), "Service Usage API is enabled")
		assert.Equal("ENABLED", apis.Get("#(config.name==\"compute.googleapis.com\").state").String(), "Compute Engine API is enabled")
		assert.Equal("ENABLED", apis.Get("#(config.name==\"servicemanagement.googleapis.com\").state").String(), "Service Management API is enabled")

		// Use Service Usage API to get display consumer quota information
		httpClient, err := google.DefaultClient(context.Background(), "https://www.googleapis.com/auth/cloud-platform")
		assert.NoError(err)
		serviceUsageEndpoint := fmt.Sprintf(
			"https://serviceusage.googleapis.com/v1beta1/projects/%s/services/%s/consumerQuotaMetrics/%s/limits/%s/consumerOverrides",
			projectID,
			"compute.googleapis.com",
			url.QueryEscape("compute.googleapis.com/n2_cpus"),
			url.QueryEscape("/project/region"))
		resp, err := httpClient.Get(serviceUsageEndpoint)
		assert.NoError(err)

		defer resp.Body.Close()

		body, err := io.ReadAll(resp.Body)
		assert.NoError(err)
		result := utils.ParseJSONResult(t, string(body))
		assert.Equal("10", result.Get("overrides.0.overrideValue").String(), "has correct consumer quota override value")
		assert.Equal("us-central1", result.Get("overrides.0.dimensions.region").String(), "has correct consumer quota override dimensions")

		serviceUsageEndpoint = fmt.Sprintf(
			"https://serviceusage.googleapis.com/v1beta1/projects/%s/services/%s/consumerQuotaMetrics/%s/limits/%s/consumerOverrides",
			projectID,
			"servicemanagement.googleapis.com",
			url.QueryEscape("servicemanagement.googleapis.com/default_requests"),
			url.QueryEscape("/min/project"))
		resp, err = httpClient.Get(serviceUsageEndpoint)
		assert.NoError(err)
		body, err = io.ReadAll(resp.Body)
		assert.NoError(err)
		result = utils.ParseJSONResult(t, string(body))
		assert.Equal("95", result.Get("overrides.0.overrideValue").String(), "has correct consumer quota override value")
		assert.False(result.Get("overrides.0.dimensions").Exists(), "has empty dimensions")
	})
	quotaProjectT.Test()
}
