How to run WDS and Postgres within Minikube (Minikube is a local k8s cluster provider)

1. Make sure you have minikube and helm installed (can use homebrew)

2. `minikube start`

3. First (even though this is not the first step, or maybe it is if you already have `minikube` running locally), run `kubectl config use-context minikube`. Ensure that you are assigned locally to the right k8s context so that
you do not push updates to any other k8s cluster.

4. Then, make whatever changes you'd like in `wds-azure-helm` (to also note, make sure `terra-batch-libchart` is nested within
the `charts/` subdirectory -- `wds-azure-helm` uses it as a dependency)

5. After making your changes, bump the semantic version in the `wds-azure-helm/Chart.yaml` to make sure your new chart is unique.

6. Run `helm package wds-azure-helm/ -d charts/` -- this will create the packaged .tgz chart with other charts in the `cromwhelm` repository.

7. Run `helm install charts/wds-azure-helm-<semantic-version>.tgz --generate-name` -- wait until you see a successful `DEPLOYED`

8. `minikube service --all` will then show you the relevant URLs to invoke WDS endpoints locally
 
9. Go to ` wds-azure-helm-<some-random-values>-wds-svc` Service and us the URL -- enter the `<url>:<port>/swagger/swagger-ui.html#/` to get Swagger docs!