{{- define "terra-batch-libchart.cbas-ui-service.tpl" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "app.fullname" . }}-batch-analysis-ui-svc
  labels:
  {{- include "app.labels" . | nindent 4 }}
spec:
  selector:
  {{- include "app.batchAnalysisUI.selectorLabels" . | nindent 4 }}
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
{{- end -}}
{{- define "terra-batch-libchart.cbas-ui-service" -}}
{{- include "terra-batch-libchart.util.merge" (append . "terra-batch-libchart.cbas-ui-service.tpl") -}}
{{- end -}}