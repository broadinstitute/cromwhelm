This helm chart is used to deploy Cromwell as an app within Leonardo. 

Here is a suggested workflow for testing updates to this chart from local Terminal, without redeploying Leonardo/Cromwell.

1. Create a workspace in Leonardo and deploy a Cromwell usage via Swagger (https://leonardo-fiab.dsde-dev.broadinstitute.org:30443/#/apps/createApp)

2. From a Terminal (not within the Leo VM… just on your local computer), do the following commands to set helm/kubectl to point to the right environment:
   - gcloud auth login (Select your test.firecloud.org account)
   - gcloud config set project <workspace project ID> (for example, terra-test-5dea92eb)
   - gcloud container clusters get-credentials --zone=us-central1-a <cluster name> (for example, kecd4047-a970-4088-89dd-003288bcf6f1, see in Google Cloud console, to the right of the Cromwell service)

3. Now you can edit the helm chart locally in your favorite editor. To update the instance of Cromwell running with your new chart, do the following from the directory in which `cromwell-helm` lives:
   - helm upgrade --namespace=<namepace> <release> cromwell 
   - Note: you can see the namespace in Google Cloud console to the right of the Cromwell service. Release is the same, with “ns” replaced by “rls”.
     So for example: helm upgrade --namespace=jlfcsv-gxy-ns jlfcsv-gxy-rls cromwell