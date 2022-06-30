{{- define "terra-batch-libchart.reverse-proxy-service.tpl" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "app.fullname" . }}-reverse-proxy-service
  labels:
  {{- include "app.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  selector:
    {{- include "app.selectorLabels" . | nindent 4 }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.port }}
{{- end -}}
{{- define "terra-batch-libchart.reverse-proxy-service" -}}
{{- include "terra-batch-libchart.util.merge" (append . "terra-batch-libchart.reverse-proxy-service.tpl") -}}
{{- end -}}