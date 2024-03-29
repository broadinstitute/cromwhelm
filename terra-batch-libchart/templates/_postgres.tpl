{{- define "terra-batch-libchart.postgres-deploy.tpl" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "app.fullname" . }}-postgres-depl
spec:
  replicas: 1
  selector:
    matchLabels:
      component: postgres
  template:
    metadata:
      labels:
        component: postgres
    spec:
      volumes:
        - name: postgres-data
          persistentVolumeClaim:
            claimName: {{ include "app.fullname" . }}-postgres-pvc
        - name: {{ include "app.fullname" . }}-postgres-startup
          configMap:
            name: {{ include "app.fullname" . }}-postgres-startup
            items:
              - key: {{ .Values.postgres.startup_scripts.create_dbs }}
                path: {{ .Values.postgres.startup_scripts.create_dbs }}
      containers:
        - name: postgres-container
          image: {{ .Values.postgres.image }}
          ports:
            - containerPort: {{ .Values.postgres.port }}
          volumeMounts:
            - name: postgres-data
              mountPath: /var/lib/postgresql/data
              subPath: postgres
            - name: {{ include "app.fullname" . }}-postgres-startup
              mountPath: {{ .Values.postgres.startup_dir }}/{{ .Values.postgres.startup_scripts.create_dbs }}
              subPath: {{ .Values.postgres.startup_scripts.create_dbs }}
          env:
            - name: POSTGRES_PASSWORD
              value: {{ include "dbPassword" . | b64enc | quote }}
            - name: POSTGRES_USER
              value: {{ .Values.postgres.user }}
            - name: POSTGRES_MULTIPLE_DATABASES
              value: "{{ .Values.postgres.dbnames.cromwell }},{{ .Values.postgres.dbnames.cbas }},{{ .Values.postgres.dbnames.tes }}"
{{- end -}}
{{- define "terra-batch-libchart.postgres-deploy" -}}
{{- include "terra-batch-libchart.util.merge" (append . "terra-batch-libchart.postgres-deploy.tpl") -}}
{{- end -}}


{{- define "terra-batch-libchart.postgres-service.tpl" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "app.fullname" . }}-postgres
spec:
  type: ClusterIP
  selector:
    component: postgres
  ports:
    - port: {{ .Values.postgres.port }}
      targetPort: {{ .Values.postgres.port }}
{{- end -}}
{{- define "terra-batch-libchart.postgres-service" -}}
{{- include "terra-batch-libchart.util.merge" (append . "terra-batch-libchart.postgres-service.tpl") -}}
{{- end -}}


{{- define "terra-batch-libchart.postgres-config.tpl" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "app.fullname" . }}-postgres-startup
data:
  {{ .Values.postgres.startup_scripts.create_dbs }}: |-
    #!/bin/bash
    # Copied from: https://github.com/mrts/docker-postgresql-multiple-databases/blob/master/create-multiple-postgresql-databases.sh

    set -e
    set -u

    function create_user_and_database() {
      local database=$1
      echo "  Creating user and database '$database'"
      psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
          CREATE USER $database;
          CREATE DATABASE $database;
          GRANT ALL PRIVILEGES ON DATABASE $database TO $database;
    EOSQL
    }

    if [ -n "$POSTGRES_MULTIPLE_DATABASES" ]; then
      echo "Multiple database creation requested: $POSTGRES_MULTIPLE_DATABASES"
      for db in $(echo $POSTGRES_MULTIPLE_DATABASES | tr ',' ' '); do
        create_user_and_database $db
      done
      echo "Multiple databases created"
    fi
{{- end -}}
{{- define "terra-batch-libchart.postgres-config" -}}
{{- include "terra-batch-libchart.util.merge" (append . "terra-batch-libchart.postgres-config.tpl") -}}
{{- end -}}
