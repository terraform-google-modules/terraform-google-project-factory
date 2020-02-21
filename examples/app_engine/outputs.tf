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

output "project_id" {
  description = "The project ID where app engine is created"
  value       = module.app-engine-project.project_id
}

output "app_name" {
  description = "Unique name of the app, usually apps/{PROJECT_ID}."
  value       = module.app-engine.name
}

output "default_hostname" {
  description = "The default hostname for this app."
  value       = module.app-engine.default_hostname
}

output "location_id" {
  description = "The location app engine is serving from"
  value       = module.app-engine.location_id
}

