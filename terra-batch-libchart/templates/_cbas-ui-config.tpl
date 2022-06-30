{{- define "cbas-libchart.cbas-ui-config.tpl" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "app.fullname" . }}-batch-analysis-ui-config
{{- end -}}
{{- define "cbas-libchart.cbas-ui-config" -}}
{{- include "cbas-libchart.util.merge" (append . "cbas-libchart.cbas-ui-config.tpl") -}}
{{- end -}}