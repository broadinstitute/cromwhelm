import os
import requests
import subprocess
import sys
import uuid


# If an app exists (which implies that it's running), return app_id. Otherwise None.
def check_for_app(env):
    list_apps_url = f'{env["leonardo_url"]}/api/google/v1/apps'
    r = requests.get(
        list_apps_url,
        headers = {
            'Authorization': f'Bearer {env["token"]}',
            'Referer': 'https://bvdp-saturn-dev.appspot.com/'
        }
    )
    r.raise_for_status()
    print(r.json())


# If a Cromwell PD exists, return pd_id. Otherwise None.
def check_for_pd(env):
    raise Exception('TODO')


# If Cromshell is installed True, else False
def check_for_cromshell():
    raise Exception('TODO')


def create_app(env, pd_id):
    raise Exception('TODO')


def get_app_details(env, app_id):
    raise Exception('TODO')


def configure_cromshell(env, app_id):
    raise Exception('TODO')


def delete_app(env, app_id, delete_pd):
    raise Exception('TODO')


def start_command(env):
    app = check_for_app(env)

    # if app is None:
    #     # Note about uuid functions: 'uuid4()' means we get the right format AND it's randomly generated
    #     app_id = uuid.uuid4()
    #     pd_id = check_for_pd(env)
    #     if pd_id is None:
    #         pd_id = uuid.uuid4()
    #     create_app(app_id, pd_id)
    #
    #     app_details = None
    #     app_status = 'PROVISIONING'
    #     while app_status == 'PROVISIONING':
    #         app_details = get_app_details(env, app_id)
    #         app_status = app_details['status']
    #
    #     if app_status == 'RUNNING':
    #         configure_cromshell(env, app_id)
    #     else:
    #         raise Error(f'Unexpected app state {app_status} for app {app_id}. If the app is left behind, try running "{sys.argv[0]} delete"')


def stop_command(env):
    app = check_for_app(env)

    if app is not None:
        delete_app(env, app, False)


def delete_command(env):
    app = check_for_app(env)

    if app is not None:
        delete_app(env, app, True)



def main():
    # Iteration 1: these ENV reads will throw errors if not set.
    env = {
        'workspace_namespace': os.environ['WORKSPACE_NAMESPACE'],
        'workspace_name': os.environ['WORKSPACE_NAME'],
        'workspace_bucket': os.environ['WORKSPACE_BUCKET'],
        'user_email': os.environ.get('PET_SA_EMAIL', default = os.environ['OWNER_EMAIL']),
        'google_project': os.environ['GOOGLE_PROJECT'],
    }

    # Determine leonardo URL from google project name (only works with post PPW projects):
    if str.startswith(env['google_project'], 'terra-dev'):
        env['leonardo_url'] = 'https://leonardo.dsde-dev.broadinstitute.org/'
        env['referer'] = 'https://bvdp-saturn-dev.appspot.com/'
    else:
        env['leonardo_url'] = 'https://leonardo.dsde-prod.broadinstitute.org/'
        env['referer'] = 'https://app.terra.bio/'

    # Fetch the token:
    token_fetch_command = subprocess.Popen(['gcloud', 'auth', 'print-access-token', env['user_email']])
    if subprocess.returncode == 0:
        env['token'], _ = subprocess.communicate()
    else:
        raise Exception(f'Bad token fetch: {subprocess.communicate()}')

    if sys.argv[1] == 'start':
        start_command(env)
    elif sys.argv[1] == 'stop':
        stop_command(env)
    elif sys.argv[1] == 'delete':
        delete_command(env)
    else:
        raise Exception(f'Unknown command {sys.argv[1]}')


if __name__ == "main":
    main()