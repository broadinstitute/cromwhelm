{{- define "terra-batch-libchart.cbas-ui-config.tpl" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "app.fullname" . }}-batch-analysis-ui-config
{{- end -}}
{{- define "terra-batch-libchart.cbas-ui-config" -}}
{{- include "terra-batch-libchart.util.merge" (append . "terra-batch-libchart.cbas-ui-config.tpl") -}}
{{- end -}}