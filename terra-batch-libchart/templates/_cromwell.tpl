{{- define "terra-batch-libchart.cromwell-deploy.tpl" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "app.fullname" . }}-cromwell-depl
  labels:
    {{- include "app.labels" . | nindent 4 }}
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      {{- include "app.cromwell.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "app.cromwell.selectorLabels" . | nindent 8 }}
{{- end -}}
{{- define "terra-batch-libchart.cromwell-deploy" -}}
{{- include "terra-batch-libchart.util.merge" (append . "terra-batch-libchart.cromwell-deploy.tpl") -}}
{{- end -}}


{{- define "terra-batch-libchart.cromwell-service.tpl" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "app.fullname" . }}-cromwell-svc
  labels:
  {{- include "app.labels" . | nindent 4 }}
spec:
  selector:
  {{- include "app.cromwell.selectorLabels" . | nindent 4 }}
  ports:
    - name: {{ .Values.cromwell.port | quote }}
      protocol: TCP
      port: {{ .Values.cromwell.port }}
      targetPort: {{ .Values.cromwell.port }}
{{- end -}}
{{- define "terra-batch-libchart.cromwell-service" -}}
{{- include "terra-batch-libchart.util.merge" (append . "terra-batch-libchart.cromwell-service.tpl") -}}
{{- end -}}


{{- define "terra-batch-libchart.cromwell-config.tpl" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "app.fullname" . }}-cromwell-config
{{- end -}}
{{- define "terra-batch-libchart.cromwell-config" -}}
{{- include "terra-batch-libchart.util.merge" (append . "terra-batch-libchart.cromwell-config.tpl") -}}
{{- end -}}


{{- define "terra-batch-libchart.cromwell-config.database.conf" -}}

database {
  profile = "slick.jdbc.HsqldbProfile$"
  db {
    driver = "org.hsqldb.jdbcDriver"
    url = """
    jdbc:hsqldb:file:cromwell-executions/cromwell-db/cromwell-db;
    shutdown=false;
    hsqldb.default_table_type=cached;hsqldb.tx=mvcc;
    hsqldb.result_max_memory_rows=10000;
    hsqldb.large_data=true;
    hsqldb.applog=1;
    hsqldb.lob_compressed=true;
    hsqldb.script_format=3
    """
    connectionTimeout = 120000
    numThreads = 1
   }
}

{{- end }}
