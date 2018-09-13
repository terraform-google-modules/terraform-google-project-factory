#!/usr/bin/env python3

import argparse
import json
import logging
import sys
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from google.oauth2 import service_account


logger = logging.getLogger(__name__)


def create_parser():
    """
    Function to parse and return arguments passed in.
    """
    parser = argparse.ArgumentParser(
        description='Manage service account membership in G Suite groups.'
    )

    parser.add_argument(
            '--project_id',
            help='The project containing the service accounts to manage.')
    parser.add_argument(
            '--path',
            help='The service account credentials file.')
    parser.add_argument(
            '--email',
            help='The email address to impersonate when managing '
                 'group membership.')
    parser.add_argument('--service_accounts', help='json of service accounts')
    parser.add_argument('--action', help='')

    return parser


class GsuiteAPI(object):

    SCOPES = [
        'https://www.googleapis.com/auth/admin.directory.group',
        'https://www.googleapis.com/auth/admin.directory.group.member'
    ]

    def __init__(self, credentials_path=None, email=None):
        if credentials_path is None:
            raise Exception("Missing service account credentials file")

        if email is None:
            raise Exception("Missing directory admin email address")

        self.create_service(credentials_path, email)

    def create_service(self, credentials_path, email):
        """
        Load service account credentials from disk and then impersonate the
        user with Directory Admin permissions on the target domain.

        The service account needs access to act as the provided user account.
        For more information see
        https://developers.google.com/admin-sdk/directory/v1/guides/delegation
        """
        credentials = service_account.Credentials.from_service_account_file(
                credentials_path,
                scopes=self.__class__.SCOPES)
        delegated = credentials.with_subject(email)

        self.service = build('admin', 'directory_v1', credentials=delegated)

    def add_members(self, project_id, service_accounts):
        ca_dict = json.loads(service_accounts)

        succeeded = True
        for ca in ca_dict:
            for group in ca.get('groups', []):

                account_id = ca.get('account_id', None)

                try:
                    if account_id is not None:
                        email = '{0}@{1}.iam.gserviceaccount.com'.format(
                                account_id, project_id)

                        logger.info("Adding {} to {}".format(email, group))
                        self.service.members().insert(
                            groupKey=group,
                            body={'email': email}
                        ).execute()

                except HttpError as exception:
                    msg = '{0} - {1}'.format(email, exception._get_reason())
                    logger.error(msg)
                    succeeded = False

        return succeeded

    def remove_members(self, project_id, service_accounts):
        ca_dict = json.loads(service_accounts)

        succeeded = True
        for ca in ca_dict:
            for group in ca.get('groups', []):

                account_id = ca.get('account_id', None)

                try:
                    if account_id is not None:
                        email = '{0}@{1}.iam.gserviceaccount.com'.format(
                                account_id, project_id)

                        logger.info("Removing {} from {}".format(email, group))
                        self.service.members().delete(
                            groupKey=group,
                            memberKey=email
                        ).execute()

                except HttpError as exception:
                    msg = '{0} - {1}'.format(email, exception._get_reason())
                    logger.error(msg)
                    succeeded = True

        return succeeded


def main():

    parser = create_parser()
    args = parser.parse_args()

    gsuite_api = GsuiteAPI(
        credentials_path=args.path,
        email=args.email,
    )

    if args.action == 'add':
        succeeded = gsuite_api.add_members(
                args.project_id,
                args.service_accounts)
        if not succeeded:
            sys.exit(1)

    elif args.action == 'destroy':
        succeeded = gsuite_api.remove_members(
                args.project_id,
                args.service_accounts)
        if not succeeded:
            sys.exit(1)

    else:
        logger.fatal(
            "Unhandled action '{}', " +
            "must be one of ('add', 'destroy')".format(args.action))
        sys.exit(1)


if __name__ == '__main__':
    logging.basicConfig(level=logging.ERROR)
    logger.setLevel(logging.INFO)
    main()
