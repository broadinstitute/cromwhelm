{{- define "cromwell-common.cbas-api-config.tpl" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "app.fullname" . }}-cbas-config
data:
  {{ .Values.config.cbas.conf_file }}: |-
    workflow-engines:
      cromwell:
        baseUri: "http://{{ include "app.fullname" . }}-cromwell-svc:8000"
        healthUri: "http://{{ include "app.fullname" . }}-cromwell-svc:8000/engine/v1/status"

{{- end -}}
{{- define "cromwell-common.cbas-api-config" -}}
{{- include "cromwell-common.util.merge" (append . "cromwell-common.cbas-api-config.tpl") -}}
{{- end -}}