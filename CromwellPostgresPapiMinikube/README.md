To run this in minikube:

1. Make sure you have minikube and helm installed (can use homebrew)
2. `minikube start`
3. `minikube addons enable metallb `
4. `minikube ip` (to get IP address of minikube)
5. `minikube addons configure metallb`, Specify Load Balancer IP range based on minikube ip, eg. 192.168.49.105 to  192.168.49.120)
6. `helm install cromwell-postgres CromwellPostgresMinikubeMinikube` 
7. `minikube dashboard`, Check postgres and cromwell pods are happy. If not, delete them so they automatically restart 
8. `minikube service cromwell-service`

In the Swagger browser tab that opened, deploy a hello world WDL and verify it produces output! There are 2 sample WDLs
in the repo; use the docker one for submitting to PAPI.

To redeploy the helm chart, execute
`helm uninstall cromwell-postgres; helm install cromwell-postgres CromwellPostgresMinikubeMinikube`
