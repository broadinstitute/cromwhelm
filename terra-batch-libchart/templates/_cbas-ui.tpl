{{- define "terra-batch-libchart.cbas-ui-deploy.tpl" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "app.fullname" . }}-batch-analysis-ui-depl
  labels:
    {{- include "app.labels" . | nindent 4 }}
spec:
  replicas: 1
  selector:
    matchLabels:
      {{- include "app.batchAnalysisUI.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "app.batchAnalysisUI.selectorLabels" . | nindent 8 }}
    spec:
      hostname: {{ .Values.batchAnalysisUI.name }}
      volumes:
        - name: {{ include "app.fullname" . }}-batch-analysis-ui-config
          configMap:
            name: {{ include "app.fullname" . }}-batch-analysis-ui-config
            items:
              - key: {{ .Values.config.cbasUI.conf_file }}
                path: {{ .Values.config.cbasUI.conf_file }}
      containers:
        - name: {{ .Values.batchAnalysisUI.name }}-container
          image: us.gcr.io/broad-dsp-gcr-public/cbas-ui:0.0.1
          imagePullPolicy: Always
          ports:
            - containerPort: 8080
          volumeMounts:
            - name: {{ include "app.fullname" . }}-batch-analysis-ui-config
              mountPath: {{ .Values.config.cbasUI.conf_dir }}/{{ .Values.config.cbasUI.conf_file }}
              subPath: {{ .Values.config.cbasUI.conf_file }}

{{- end -}}
{{- define "terra-batch-libchart.cbas-ui-deploy" -}}
{{- include "terra-batch-libchart.util.merge" (append . "terra-batch-libchart.cbas-ui-deploy.tpl") -}}
{{- end -}}


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


{{- define "terra-batch-libchart.cbas-ui-config.tpl" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "app.fullname" . }}-batch-analysis-ui-config
{{- end -}}
{{- define "terra-batch-libchart.cbas-ui-config" -}}
{{- include "terra-batch-libchart.util.merge" (append . "terra-batch-libchart.cbas-ui-config.tpl") -}}
{{- end -}}
