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
	// Read setup outputs first so we can construct the project_tags map,
	// which is a map(string) and cannot be auto-mapped from setup string outputs.
	setup := tft.NewTFBlueprintTest(t, tft.WithTFDir("../../test/setup"))
	tagInlineKey := setup.GetStringOutput("tag_inline_key")
	tagInlineValue := setup.GetStringOutput("tag_inline_value")

	tagsProjectT := tft.NewTFBlueprintTest(t,
		tft.WithVars(map[string]interface{}{
			// project_tags applies resource manager tags atomically at project creation
			// via google_project.tags, satisfying GOVERN_TAGS requireTag* org policies.
			// Uses a separate tag key from tag_binding_values to avoid key conflicts.
			"project_tags": map[string]string{
				tagInlineKey: tagInlineValue,
			},
		}),
	)

	tagsProjectT.DefineVerify(func(assert *assert.Assertions) {
		tagsProjectT.DefaultVerify(assert)

		projectNum := tagsProjectT.GetStringOutput("project_num")

		// tag_value is the numeric ID used by tag_binding_values (post-creation binding).
		tagValue := tagsProjectT.GetTFSetupStringOutput("tag_value")

		parent := fmt.Sprintf("//cloudresourcemanager.googleapis.com/projects/%s", projectNum)
		projBindings := gcloud.Runf(t, "resource-manager tags bindings list --parent=%s", parent).Array()

		// Expect two bindings: one from tag_binding_values (post-creation), one from tags (inline at creation).
		assert.Len(projBindings, 2, "expected two tag bindings: one post-creation via tag_binding_values, one inline via google_project.tags")

		// Verify the post-creation binding created by tag_binding_values.
		postBinding := utils.GetFirstMatchResult(t, projBindings, "tagValue", fmt.Sprintf("tagValues/%s", tagValue))
		assert.NotNilf(postBinding, "expected post-creation binding to tagValues/%s", tagValue)

		// Verify the inline binding created by google_project.tags at creation time.
		inlineBinding := utils.GetFirstMatchResult(t, projBindings, "tagValue", tagInlineValue)
		assert.NotNilf(inlineBinding, "expected inline binding to %s (created atomically at project creation)", tagInlineValue)
	})
	tagsProjectT.Test()
}
