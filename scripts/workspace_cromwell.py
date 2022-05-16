import os
import json
from pathlib import Path
import requests
import subprocess
import sys
import time
import uuid


# If a CROMWELL app exists return (app_name, status), otherwise (None, None).
def check_for_app(env):
    list_apps_url = f'{env["leonardo_url"]}/api/google/v1/apps/{env["google_project"]}'
    r = requests.get(
        list_apps_url,
        params={
          'includeDeleted': 'false'
        },
        headers = {
            'Authorization': f'Bearer {env["token"]}'
        }
    )
    r.raise_for_status()

    for potential_app in r.json():
        if potential_app['appType'] == 'CROMWELL' and (
                str(potential_app['auditInfo']['creator']) == env['owner_email']
                or str(potential_app['auditInfo']['creator']) == env['user_email']
        ) :
            potential_app_name = potential_app['appName']
            potential_app_status = potential_app['status']

            # We found a CROMWELL app in the correct google project and owned by the user. Now just check the workspace:
            _, workspace_namespace, workspace_name, _ = get_app_details(env, potential_app_name)
            if workspace_namespace == env['workspace_namespace'] and workspace_name == env['workspace_name']:
                return potential_app_name, potential_app_status

    return None, None


# Returns (status, workspace_namespace, workspace_name, proxyUrls) for a running app, (None, None, None, None) for a missing/shutdown one:
def get_app_details(env, app_name):
    get_app_url = f'{env["leonardo_url"]}/api/google/v1/apps/{env["google_project"]}/{app_name}'
    r = requests.get(
        get_app_url,
        params={
            'includeDeleted': 'true'
        },
        headers={
            'Authorization': f'Bearer {env["token"]}'
        }
    )
    if r.status_code == 404:
        return 'DELETED', None, None, None
    else:
        r.raise_for_status()
    result_json = r.json()
    custom_environment_variables = result_json['customEnvironmentVariables']
    return result_json['status'], custom_environment_variables['WORKSPACE_NAMESPACE'], custom_environment_variables['WORKSPACE_NAME'], result_json.get('proxyUrls')


# If a Cromwell PD exists, return pd_name. Otherwise None.
def check_for_pd(env):
    list_apps_url = f'{env["leonardo_url"]}/api/google/v1/disks/{env["google_project"]}'
    r = requests.get(
        list_apps_url,
        params={
            'saturnApplication': 'CROMWELL',
            'includeDeleted': 'false'
        },
        headers={
            'Authorization': f'Bearer {env["token"]}'
        }
    )
    r.raise_for_status()

    for potential_disk in r.json():
        if (str(potential_disk['auditInfo']['creator']) == env['owner_email'] or
                str(potential_disk['auditInfo']['creator']) == env['user_email']):
            return potential_disk['name']

    return None


# Submits the request to create an app (note: does not block while creation completes)
def create_app(env, app_name, pd_name, create_pd):
    create_app_url = f'{env["leonardo_url"]}/api/google/v1/apps/{env["google_project"]}/{app_name}'

    if create_pd:
        disk_config = {
            'name': pd_name,
            'size': 500,
            'labels': {
                'saturnApplication': 'CROMWELL',
                'saturnWorkspaceNamespace': env['workspace_namespace'],
                'saturnWorkspaceName': env['workspace_name']
            }
        }
    else:
        disk_config = {
            'name': pd_name
        }

    r = requests.post(
        create_app_url,
        json = {
            'labels': {
                'saturnWorkspaceNamespace': env['workspace_namespace'],
                'saturnWorkspaceName': env['workspace_name']
            },
            'diskConfig': disk_config,
            "customEnvironmentVariables": {
                'WORKSPACE_NAME': env['workspace_name'],
                'WORKSPACE_NAMESPACE': env['workspace_namespace'],
                'WORKSPACE_BUCKET': env['workspace_bucket'],
                'GOOGLE_PROJECT': env['google_project'],
            },
            'appType': 'CROMWELL'
        },
        headers = {
            'Authorization': f'Bearer {env["token"]}'
        }
    )
    r.raise_for_status()


# Checks that cromshell is installed. Otherwise raises an error.
def validate_cromshell():
    print('Scanning for cromshell 2...')
    validate_command = subprocess.run(['cromshell-alpha', 'version'], capture_output=True, check=True, encoding='utf-8')
    version = str.strip(validate_command.stderr).split(' cromshell ')[-1]
    print(f'Cromshell 2 version detected: {version}')


def configure_cromshell(env, proxy_url):
    file = f'{str(Path.home())}/.cromshell/cromshell_config.json'
    configuration = {
        'cromwell_server': proxy_url.split("swagger/", 1)[0],
        'requests_timeout': 5,
        'gcloud_token_email': env['user_email'],
        'referer_header_url': env['referer']
    }
    with open(file, 'w') as filetowrite:
        filetowrite.write(json.dumps(configuration, indent=2))


# Submits the request to delete an app (note: does not block while deletion completes)
def delete_app(env, app_name, delete_pd):
    delete_app_url = f'{env["leonardo_url"]}/api/google/v1/apps/{env["google_project"]}/{app_name}'
    r = requests.delete(
        delete_app_url,
        params={
            # Do the boolean-to-string manually to make sure it's lowercased correctly:
            'deleteDisk': 'true' if delete_pd else 'false'
        },
        headers={
            'Authorization': f'Bearer {env["token"]}'
        }
    )
    r.raise_for_status()


def start_command(env):
    app_name, app_status = check_for_app(env)

    print(f'app_name={app_name}; app_status={app_status}')

    if app_name is None:
        # Note about uuid functions: 'uuid4()' means we get the right format AND it's randomly generated
        app_name = f'terra-app-{uuid.uuid4()}'
        print(f'CROMWELL app does not exist. Creating new app with name {app_name}')
        pd_name = check_for_pd(env)
        if pd_name is None:
            create_pd = True
            pd_name = f'saturn-pd-{uuid.uuid4()}'
            print(f'CROMWELL disk not found. Creating new disk with name {pd_name}')
        else:
            create_pd = False
            print(f'Existing CROMWELL disk found with name {pd_name}. Reconnecting.')
        create_app(env, app_name, pd_name, create_pd)

        app_status = 'PROVISIONING'
        proxy_urls = {}
        print('Waiting for Cromwell app to come up...')
        while app_status == 'PROVISIONING':
            time.sleep(10)
            app_status, _, _, proxy_urls = get_app_details(env, app_name)
            print(f'Current {app_name} status: {app_status}...')

        if app_status == 'RUNNING':
            configure_cromshell(env, proxy_urls['cromwell-service'])
        else:
            raise Exception(f'Unexpected app state {app_status} for app {app_name}. If the app is left behind, try running "{sys.argv[0]} delete"')

        print('Cromwell app successfully and cromshell2 has been configured to access it')
    else:
        print(f'Existing CROMWELL app found (app_name={app_name}; app_status={app_status}).')
        exit(1)


def status_command(env):
    print(f'Scanning from CROMWELL apps and disks for {env["user_email"]} in {env["workspace_namespace"]}/{env["workspace_name"]}')

    app_name, status = check_for_app(env)
    pd_name = check_for_pd(env)

    if app_name is None:
        if pd_name is None:
            print('No CROMWELL app detected. No persistent state detected.')
        else:
            print(f'CROMWELL app stopped. Persistent disk {pd_name} is still available.')
    else:
        print(f'CROMWELL app detected with name {app_name} and persistent disk {pd_name}.')


def stop_command(env):
    app_name, app_status = check_for_app(env)
    pd_name = check_for_pd(env)

    print(f'app_name={app_name}; app_status={app_status}, pd_name={pd_name}')

    print(f'Will remove the app but leave the persistent disk which can be reconnected to.')

    if app_name is not None:
        delete_app(env, app_name, False)


def delete_command(env):
    app_name, app_status = check_for_app(env)

    print(f'app_name={app_name}; app_status={app_status}')
    pd_name = check_for_pd(env)

    if app_name is None:
        if pd_name is None:
            print(f'Cannot continue. Existing CROMWELL app not found.')
            exit(1)
        else:
            print('CROMWELL app stopped. Deleting persistent disk...')
            raise Exception('TODO: Delete from stopped. For now, you can run "start" and then delete to remove the disk.')
    else:
        delete_app(env, app_name, delete_pd=True)

        app_status = 'DELETING'
        print('Waiting for Cromwell app to be deleted...')
        while app_status == 'DELETING':
            time.sleep(10)
            app_status, _, _, _ = get_app_details(env, app_name)
            print(f'Current {app_name} status: {app_status}...')

        if app_status == 'DELETED':
            print(f'CROMWELL app {app_name} and its persistent disk have been deleted successfully.')
        else:
            raise Exception(f'Unexpected app state {app_status} for app {app_name}.')


def main():
    # Iteration 1: these ENV reads will throw errors if not set.
    env = {
        'workspace_namespace': os.environ['WORKSPACE_NAMESPACE'],
        'workspace_name': os.environ['WORKSPACE_NAME'],
        'workspace_bucket': os.environ['WORKSPACE_BUCKET'],
        'user_email': os.environ.get('PET_SA_EMAIL', default = os.environ['OWNER_EMAIL']),
        'owner_email': os.environ['OWNER_EMAIL'],
        'google_project': os.environ['GOOGLE_PROJECT'],
    }

    # Determine leonardo URL from google project name (only works with post PPW projects):
    if str.startswith(env['google_project'], 'terra-dev'):
        env['leonardo_url'] = 'https://leonardo.dsde-dev.broadinstitute.org/'
        env['referer'] = 'https://bvdp-saturn-dev.appspot.com/'
    else:
        env['leonardo_url'] = 'https://leonardo.dsde-prod.broadinstitute.org/'
        env['referer'] = 'https://app.terra.bio/'

    # Before going any further, check that cromshell2 is installed:
    validate_cromshell()

    # Fetch the token:
    token_fetch_command = subprocess.run(['gcloud', 'auth', 'print-access-token', env['user_email']], capture_output=True, check=True, encoding='utf-8')
    env['token'] = str.strip(token_fetch_command.stdout)

    if sys.argv[1] == 'start':
        start_command(env)
    elif sys.argv[1] == 'status':
        status_command(env)
    elif sys.argv[1] == 'stop':
        stop_command(env)
    elif sys.argv[1] == 'delete':
        delete_command(env)
    else:
        raise Exception(f'Unknown command {sys.argv[1]}')


if __name__ == '__main__':
    main()