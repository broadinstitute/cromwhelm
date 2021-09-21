To run this in minikube:

1. Make sure you have minikube and helm installed (can use homebrew)
2. `minikube start`
3. `minikube addons enable metallb `
4. `minikube ip` (to get IP address of minikube)
5. `minikube addons configure metallb`, Specify Load Balancer IP range based on minikube ip, eg. 192.168.49.105 to  192.168.49.120)
6. `helm install cromwell-hsqldb-local CromwellHsqldbLocalMinikube` 
7. `minikube dashboard`, Check the cromwell pod is happy. If not, delete it so it automatically restart. 
8. `minikube service cromwell-service`

In the Swagger browser tab that opened, deploy a hello world WDL and verify it produces output! There are 2 sample WDLs
in the repo; use the non-dockerized one for submitting locally.

To redeploy the helm chart, execute:
```
helm uninstall cromwell-hsqldb-local;
helm install cromwell-hsqldb-local CromwellHsqldbLocalMinikube
```
