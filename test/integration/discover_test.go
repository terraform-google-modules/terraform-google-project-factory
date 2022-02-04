// Copyright 2022 Google LLC
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

package test

import (
  // should be imported to enable testing for GO modules
  "testing"

  // should be imported to use terraform helpers in blueprints test framework
  "github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
)

// entry function for the test; can be named as Test*
func TestAll(t *testing.T) {
   // the helper to autodiscover and test blueprint examples
   tft.AutoDiscoverAndTest(t)
}
