/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/******************************************
  Provider configuration
 *****************************************/
provider "google" {
  version = "~> 3.30"
}

provider "google-beta" {
  version = "~> 3.38"
}

module "essential-contacts" {
  source                      = "../../modules/essential_contacts"
  project_id                  = var.project_id

  essential_contacts_config = [{
    notification_category_subscriptions = ["ALL"]
    language              = "en-US"
    contacts = [
      "user@foo.com",
      "group@foo.com"
      ]  
  }]
}
