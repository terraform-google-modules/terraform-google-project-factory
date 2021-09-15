/**
 * Copyright 2021 Google LLC
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

locals {
  essential_contacts = flatten([
    for config in var.essential_contacts_config : [
      for contact in config.contacts : {
        email = contact, 
        notification_category_subscriptions = config.notification_category_subscriptions, 
        language_tag = config.language 
      }
    ]
  ])
}

/******************************************
  Essential Contact configuration
 *****************************************/

resource "google_essential_contacts_contact" "contact" {
  for_each = {
    for contact in local.essential_contacts :
    "${contact.notification_category_subscriptions}.${language_tag}.${contact.user}" => contact
  }
  
  parent                              = data.google_project.project.id
  email                               = each.value.email
  language_tag                        = each.value.language_tag
  notification_category_subscriptions = each.value.notification_category_subscriptions
}
