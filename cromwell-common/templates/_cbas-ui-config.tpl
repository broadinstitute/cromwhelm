{{- define "cromwell-common.cbas-ui-config.tpl" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "app.fullname" . }}-batch-analysis-ui-config
{{- end -}}
{{- define "cromwell-common.cbas-ui-config" -}}
{{- include "cromwell-common.util.merge" (append . "cromwell-common.cbas-ui-config.tpl") -}}
{{- end -}}