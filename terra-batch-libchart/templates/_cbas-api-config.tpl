{{- define "cbas-libchart.cbas-api-config.tpl" -}}
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
{{- define "cbas-libchart.cbas-api-config" -}}
{{- include "cbas-libchart.util.merge" (append . "cbas-libchart.cbas-api-config.tpl") -}}
{{- end -}}