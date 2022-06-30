{{- define "cbas-libchart.cbas-ui-service.tpl" -}}
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
{{- define "cbas-libchart.cbas-ui-service" -}}
{{- include "cbas-libchart.util.merge" (append . "cbas-libchart.cbas-ui-service.tpl") -}}
{{- end -}}