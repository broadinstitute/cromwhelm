**WARNING: This chart is in active development. You will not be able to deploy it without significant manual setup.**

This chart is used for deploying Cromwell as an App on Azure,
using the Composite Batch Analysis Service (C-BAS) web interface.

At the time of this writing, deploying this chart requires multiple manual steps
that are out of the scope of this README. 
You should not attempt to deploy it without understanding these manual steps (not described here).

Notes for deploying:
- This chart depends on the Library Chart `cbas-libchart`. At the top level of this repository, run `helm dependency update coa-helm` to populate `coa-helm/charts` with the packaged `cbas-libchart` dependency.
- After running `helm dependency update coa-helm`, run `helm upgrade -f your_local_values.yaml cromwell-azure ./coa-helm`