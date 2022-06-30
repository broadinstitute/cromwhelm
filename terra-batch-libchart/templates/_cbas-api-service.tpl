{{- define "terra-batch-libchart.cbas-api-service.tpl" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "app.fullname" . }}-cbas-svc
  labels:
  {{- include "app.labels" . | nindent 4 }}
spec:
  selector:
  {{- include "app.cbas.selectorLabels" . | nindent 4 }}
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
{{- end -}}
{{- define "terra-batch-libchart.cbas-api-service" -}}
{{- include "terra-batch-libchart.util.merge" (append . "terra-batch-libchart.cbas-api-service.tpl") -}}
{{- end -}}