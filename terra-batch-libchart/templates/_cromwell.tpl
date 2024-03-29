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
        leoServiceName: cromwell
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
  {{- if eq ("true") (include "podLocalDatabaseEnabledForCromwellCBAS" .) }}
  db.url = "jdbc:postgresql://{{ include "app.fullname" . }}-postgres:{{ include "postgresPort" . }}/{{ .Values.postgres.dbnames.cromwell }}?useSSL=false&rewriteBatchedStatements=true&allowPublicKeyRetrieval=true"
  {{- else }}
  db.url = "jdbc:postgresql://{{ .Values.postgres.host }}:{{ include "postgresPort" . }}/{{ .Values.postgres.dbnames.cromwell }}?prepareThreshold=0&sslMode=Require&rewriteBatchedStatements=true&allowPublicKeyRetrieval=true&authenticationPluginClassName=com.azure.identity.extensions.jdbc.postgresql.AzurePostgresqlAuthenticationPlugin"
  {{- end }}
  db.user = {{ .Values.postgres.user | quote }}
  db.password = {{ include "dbPassword" . | b64enc | quote }}
  db.driver = "org.postgresql.Driver"
  profile = "slick.jdbc.PostgresProfile$"
  db.connectionTimeout = 15000
}

{{- end }}
