#! /usr/bin/env python3

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

import argparse
from googleapiclient.errors import HttpError
from googleapiclient.discovery import build
from google.oauth2 import service_account

SCOPES = ['https://www.googleapis.com/auth/admin.directory.group']


def authenticate(impersonated_user, sa_json_file_path, scopes):
    print('Getting delegated credentials for %s' % impersonated_user)

    return service_account.Credentials.from_service_account_file(
        sa_json_file_path,
        scopes=scopes,
        subject=impersonated_user
    )



def group_exists(service, group_email):
    try:
        return service.groups().get(groupKey=group_email).execute()
    except HttpError as e:
        if e.resp.status == 404:
            print('Group %s does not exist' % group_email)
            exit(1)
        else:
            print('Error fetching groups %s %s' % e.content, e.error_details)
            exit(2)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Test if the specified G Suite exists')
    parser.add_argument('--sa-json-credentials', dest='sa_json_credentials')
    parser.add_argument('--group-email', dest='group_email')
    parser.add_argument('--impersonate-user', dest='impersonate_user')
    args = parser.parse_args()

    service = build("admin",
                    "directory_v1",
                    credentials=authenticate(
                        args.impersonate_user,
                        args.sa_json_credentials,
                        SCOPES)
                    )
    group_exists(service, args.group_email)
