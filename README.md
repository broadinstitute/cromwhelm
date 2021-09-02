# cromwhelm
Tentative first steps into the world of helm charts

## Warning:

- Do NOT commit anything secret or personal to this repository!
- Be prepared for us to delete this repository imminently, it's really just here as a useful collaboration medium 
while we're iterating on the early helm charts.

## Notes on getting this far:

- Made by running `helm create cromwell-local` and then adding/messing around.
- I'm currently trying to get Cromwell and Postgres to run in the same pod. As of commit #2, that doesn't seem to be working.
- ...
- That's more or less it!

## How to test this out yourself:

- Install minikube and helm:

```
cromwhelm % brew install minikube
cromwhelm % brew install helm
```

- Install the chart (as `cromwell-local`, from `cromwell-local/`):

```
cromwhelm % helm install cromwell-local cromwell-local/ 
```

- And then to uninstall the chart:

```
cromwhelm % helm uninstall cromwell-local
```

## Open Questions:

- Is it better to have one Deployment with two containers, or two deployments with one container?
- Same question, but w.r.t. Services. 
