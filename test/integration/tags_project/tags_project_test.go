// Copyright 2024 Google LLC
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

package tags_project

import (
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
	"github.com/stretchr/testify/assert"
)

func TestTagsProject(t *testing.T) {
	tagsProjectT := tft.NewTFBlueprintTest(t)
	tagsProjectT.DefineVerify(func(assert *assert.Assertions) {
		tagsProjectT.DefaultVerify(assert)

		projectNum := tagsProjectT.GetStringOutput("project_num")
		tagValue := tagsProjectT.GetTFSetupStringOutput("tag_value")

		parent := fmt.Sprintf("//cloudresourcemanager.googleapis.com/projects/%s", projectNum)
		projBindings := gcloud.Runf(t, "resource-manager tags bindings list --parent=%s", parent).Array()
		assert.Len(projBindings, 1, "expected one binding")

		binding := utils.GetFirstMatchResult(t, projBindings, "parent", parent)
		assert.Equalf(fmt.Sprintf("tagValues/%s", tagValue), binding.Get("tagValue").String(), "expected binding to %s", tagValue)
	})
	tagsProjectT.Test()
}
