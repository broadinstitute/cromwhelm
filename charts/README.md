To update this chart repo:

- Navigate to the top-level repo directory.
- Identify which chart to package and create the appropriate new chart `tgz`: 

```shell script
helm package CHART_DIR/
```

- **_Add_** the new `tgz` file into this `charts/` directory
- Re-generate the index:

```shell script
helm repo index charts
```

This should mean that the `charts/` directory has both the new `tgz` file and an updated `index.yaml`
file. Your helm repo has been successfully updated! 

**Note**: When we have a stable URL for the repo we can include that in the indexing command
by running:
```shell script
helm repo index --url repo-base-url .
```
