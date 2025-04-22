This helm chart is used to deploy Cromwell as an app within Leonardo. 

Here is a suggested workflow for testing updates to this chart from local Terminal, without redeploying Leonardo/Cromwell.

1. Create a workspace in Leonardo and deploy a Cromwell usage via Swagger (https://leonardo-fiab.dsde-dev.broadinstitute.org:30443/#/apps/createApp)

2. From a Terminal (not within the Leo VM… just on your local computer), do the following commands to set helm/kubectl to point to the right environment:
   - Login to your `test.firecloud.org` account with the Google Cloud CLI: `gcloud auth login`
   - Configure `gcloud` to use your workspace's project: `gcloud config set project <workspace project ID>` (for example: `terra-test-5dea92eb`)
   - Identify the the GKE cluster name associated with your workspace: `gcloud container clusters list --zone=us-central1-a --project=<workspace project ID>` (the workspace project ID is the one you used in the previous step)
   - Run the following command to write the GKE cluster credentials as a `kubeconfig` entry (thereby configuring your local `kubectl` installation to communicate with the GKE cluster for your workspace): `gcloud container clusters get-credentials --zone=us-central1-a <cluster name>` (obtain the cluster name from the previous step; e.g. `kecd4047-a970-4088-89dd-003288bcf6f1`)

3. Now you can edit the helm chart locally in your favorite editor:
   - Identify the namespace: `kubectl get namespaces`
   - Identify the release: Release is the same as the namespace, with `ns` replaced by `rls` (e.g. for the namespace `abcdef-ghi-ns`, the release is `abcdef-ghi-rls`)
   - Update the instance of Cromwell running with your new chart: `helm upgrade --namespace=<namepace> <release> cromwell-helm` 
      - Note: you can also see the namespace in Google Cloud console to the right of the Cromwell service.
   - If you see `Error: UPGRADE FAILED: ...` refer to the Troubleshooting section below.


If you do want to test your chart by deploying via leonardo, you can do the following:
1. Bump the version in `Chart.yaml`
2. Build the new chart, move it to the `/charts` directory, and update the index:
   `helm dependency update cromwell-helm/`
   `helm package cromwell-helm/`
   `mv cromwell-<NEW-VERSION>.tgz charts/cromwell-<NEW-VERSION>.tgz`
   `helm repo index --url https://broadinstitute.github.io/cromwhelm/charts/ charts`
3. Commit and push the new chart to your branch
4. The charts are hosted at https://broadinstitute.github.io/cromwhelm/charts/, which is the web page hosted by the github repo. 
You need to redeploy the web page from your branch instead of main. You can do that by going into Settings > Pages > Build and deployment > Source > Deploy from a branch
5. You can now use this new version of the chart in Leonardo [here](https://github.com/DataBiosphere/leonardo/blob/68e204738a01ba34b78f673098635e4c4ef111d9/Dockerfile#L33)


**Troubleshooting**: 

You may encounter the following error when trying to run `helm upgrade`:

`Error: UPGRADE FAILED: cannot patch "<release>-depl" with kind Deployment: Deployment.apps "<release>-depl" is invalid: spec.selector: Invalid value: v1.LabelSelector{MatchLabels:map[string]string{"app.kubernetes.io/component":"cromwell-api"}, MatchExpressions:[]v1.LabelSelectorRequirement(nil)}: field is immutable`

At the time of this writing, the cause of this problem is not known to us. 
However, you can work around it by (1) deleting the deploy and (2) retrying the command:

1. `kubectl delete deploy <release>-depl --namespace=<namespace>`
2. `helm upgrade --namespace=<namepace> <release> cromwell-helm`


**Rules for granting users permissions to run workflows (as the pet itself)**:
- Add Workflow runner permissions against the project, then Service Account User permissions against ONLY the user’s pet SA:
   - In Google Cloud console for the project go to IAM & Admin → Service Accounts section. Copy the email address for pet SA
   - Now navigate to IAM section. Click on Add at the top
      - In Principals field paste in the pet SA email address
      - Add below Roles:
         - Cloud Life Sciences Workflows Runner
   - Now, navigate back to the Service Accounts section in IAM & Admin
   - From here navigate to the user’s pet SA that you want to set permissions for (double click) -- *at this step, we are in fact granting the service       account permission to act as itself when running jobs*.
      - Navigate from the ‘Details’ page to the ‘Permissions’ page to the right
      - Hit the ‘Grant Access’ button underneath the Principals with access to this service account section.
         - In Principals field, paste in the pet SA email address
         - Add the below Role:
            - Service Account User
