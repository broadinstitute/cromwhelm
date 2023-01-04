To run this in minikube (commit https://github.com/broadinstitute/cromwhelm/commit/032a1ded0f956819bf53e2bc2a1fd94d8fe73e97):

1. Make sure you have minikube and helm installed (can use homebrew)
2. `minikube start`
3. `minikube addons enable metallb `
4. `minikube ip` (to get IP address of minikube)
5. `minikube addons configure metallb`, Specify Load Balancer IP range based on minikube ip, eg. 192.168.49.105 to  192.168.49.120)
6. `helm install cromwell-postgres CromwellPostgresMinikubeMinikube` 
7. `minikube dashboard`, Check postgres and cromwell pods are happy. If not, delete them so they automatically restart 
8. `minikube service cromwell-service`

# TODO: Revisit and give credit where is due

In the Swagger browser tab that opened, deploy a hello world WDL and verify it produces output! There are 2 sample WDLs
in the repo; use the docker one for submitting to PAPI.

To redeploy the helm chart, execute
`helm uninstall cromwell-postgres; helm install cromwell-postgres CromwellPostgresMinikubeMinikube`

To run more recent versions in Cromwell Dev GCP:

1. Must have a Kubernetes cluster set up (https://console.cloud.google.com/kubernetes/clusters/details/us-central1-c/cromwell-k8s-dev)
2. Create a Cromwell SA and store credentials key as a secret in the Kubernetes cluster (steps in https://broadworkbench.atlassian.net/browse/BW-821?focusedCommentId=51309)
3. Give Cromwell SA iam.serviceAccountUser and lifesciences.workflowsRunner roles (steps in https://broadworkbench.atlassian.net/browse/BW-821?focusedCommentId=51308, but do not give bucket permissions)
4. Make sure that credentials JSON filename, key, and bucket name match what is in values.yaml.
5. Create a User SA and store JSON credentials locally. Give the User SA objectAdmin bucket permissions (and nothing else).
6. Create a workflow options JSON file with 2 entries: google_compute_service_account and user_service_account_json. Both of these should reference the User SA. Note that the JSON keys must be a single line, with newlines and quotes escaped.

````
Example options.json:
{
  "user_service_account_json": "{\"type\": \"service_account\", \"project_id\": \"broad-dsde-cromwell-dev\", ....
  "google_compute_service_account": "papi-compute-sa@broad-dsde-cromwell-dev.iam.gserviceaccount.com"
}
````

7. Install helm chart into Kubernetes cluster (same command as Minikube, as now gcloud is pointing to Cromwell Dev)
8. Submit a workflow, supplying both the wdl and the workflow options. You should get success!
9. Note that when uninstalling/installing new versions, do not concatenate the operations together. Trying to uninstall/install as a single command leads to newly launched services being killed, and/or the postrgres service failing to initialize properly. Uninstall and wait for both services to terminate before installing a new version.
