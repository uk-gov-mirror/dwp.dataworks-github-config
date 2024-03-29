#!/usr/bin/env python3

import boto3
import botocore
import jinja2
import os
import sys
import yaml
import json
import datetime
from dateutil.tz import tzlocal


def main():
    if "AWS_PROFILE" in os.environ:
        boto3.setup_default_session(profile_name=os.environ["AWS_PROFILE"])
    if "AWS_PROFILE_MGT_DEV" in os.environ:
        secrets_session = boto3.Session(profile_name=os.environ["AWS_PROFILE_MGT_DEV"])
    elif "AWS_SECRETS_ROLE" in os.environ:
        secrets_session = assumed_role_session(os.environ["AWS_SECRETS_ROLE"])
    if "AWS_REGION" in os.environ:
        ssm = boto3.client("ssm", region_name=os.environ["AWS_REGION"])
        secrets_manager = secrets_session.client(
            "secretsmanager", region_name=os.environ["AWS_REGION"]
        )
    else:
        ssm = boto3.client("ssm")
        secrets_manager = secrets_session.client("secretsmanager")

    try:
        parameter = ssm.get_parameter(
            Name="terraform_bootstrap_config", WithDecryption=False
        )
        dataworks_secret = secrets_manager.get_secret_value(
            SecretId="/concourse/dataworks/dataworks-secrets"
        )
        dataworks_sensitive = secrets_manager.get_secret_value(
            SecretId="/concourse/dataworks/dataworks"
        )
    except botocore.exceptions.ClientError as e:
        error_message = e.response["Error"]["Message"]
        if "The security token included in the request is invalid" in error_message:
            print(
                "ERROR: Invalid security token used when calling AWS SSM. Have you run `aws-sts` recently?"
            )
        else:
            print("ERROR: Problem calling AWS SSM: {}".format(error_message))
        sys.exit(1)

    config_data = yaml.load(parameter["Parameter"]["Value"], Loader=yaml.FullLoader)
    config_data['github_username'] = json.loads(dataworks_sensitive['SecretBinary'])["concourse_github_username"]
    config_data['github_email'] = json.loads(dataworks_sensitive['SecretBinary'])["concourse_github_email"]
    config_data['github_token'] = json.loads(dataworks_secret['SecretBinary'])["concourse_github_pat"]
    config_data['github_webhook_token'] = json.loads(dataworks_sensitive['SecretBinary'])["concourse_github_webhook_token"]
    config_data['dockerhub_username'] = json.loads(dataworks_sensitive['SecretBinary'])["dockerhub_username"]
    config_data['dockerhub_password'] = json.loads(dataworks_secret['SecretBinary'])["dockerhub_token"]
    config_data['snyk_token'] = json.loads(dataworks_secret['SecretBinary'])["snyk_token"]
    config_data['slack_webhook_url'] = json.loads(dataworks_sensitive['SecretBinary'])["slack_webhook_url"]
    config_data['gha_aws_concourse_access_key_id'] = json.loads(dataworks_secret['SecretBinary'])["gha_aws_concourse_access_key_id"]
    config_data['gha_aws_concourse_secret_access_key'] = json.loads(dataworks_secret['SecretBinary'])["gha_aws_concourse_secret_access_key"]

    with open("terraform.tf.j2") as in_template:
        template = jinja2.Template(in_template.read())
    with open("terraform.tf", "w+") as terraform_tf:
        terraform_tf.write(template.render(config_data))
    with open("terraform.tfvars.j2") as in_template:
        template = jinja2.Template(in_template.read())
    with open("terraform.tfvars", "w+") as terraform_tf:
        terraform_tf.write(template.render(config_data))
    print("Terraform config successfully created")


def assumed_role_session(role_arn: str, base_session: botocore.session.Session = None):
    base_session = base_session or boto3.session.Session()._session
    fetcher = botocore.credentials.AssumeRoleCredentialFetcher(
        client_creator=base_session.create_client,
        source_credentials=base_session.get_credentials(),
        role_arn=role_arn,
        extra_args={
            #    'RoleSessionName': None # set this if you want something non-default
        },
    )
    creds = botocore.credentials.DeferredRefreshableCredentials(
        method="assume-role",
        refresh_using=fetcher.fetch_credentials,
        time_fetcher=lambda: datetime.datetime.now(tzlocal()),
    )
    botocore_session = botocore.session.Session()
    botocore_session._credentials = creds
    return boto3.Session(botocore_session=botocore_session)


if __name__ == "__main__":
    main()
