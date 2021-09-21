To update this chart repo:

- Navigate to the top-level repo directory.
- Identify which chart to package and create the appropriate new chart `tgz`: 

```bash
helm package CHART_DIR/
```

- **_Add_** the new `tgz` file into this `charts/` directory
- Re-generate the index:

```bash
helm repo index --url https://broadinstitute.github.io/cromwhelm/charts/ charts
```

This should mean that the `charts/` directory has both the new `tgz` file and an updated `index.yaml`
file. Your helm repo has been successfully updated! 
