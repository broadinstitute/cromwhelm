**WARNING: This chart is in active development. You will not be able to deploy it without significant manual setup.**

This chart is used for deploying Cromwell as an App on Azure,
using the Composite Batch Analysis Service (C-BAS) web interface.

At the time of this writing, deploying this chart requires multiple manual steps
that are out of the scope of this README. 
You should not attempt to deploy it without understanding these manual steps (not described here).

Notes for deploying:
- This chart depends on the Library Chart `terra-batch-libchart`. At the top level of this repository, run `helm dependency update coa-helm` to populate `coa-helm/charts` with the packaged `terra-batch-libchart` dependency.
- Copy the contents of `local_values.template.yaml` into a new file called `local_values.yaml`, and populate this new file with the appropriate values (ask a member of the Batch team). Do not commit these new values; `local_values.yaml` should be excluded from version control by the top-level `.gitignore` file.
- After running `helm dependency update coa-helm`, run `helm upgrade -f local_values.yaml cromwell-azure ./coa-helm`
