{{- define "cbas-libchart.cbas-ui-deploy.tpl" -}}
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
          image: us.gcr.io/broad-dsp-gcr-public/terra-batch-analysis-ui:cjl_BW-1291
          imagePullPolicy: Always
          ports:
            - containerPort: 8080
          volumeMounts:
            - name: {{ include "app.fullname" . }}-batch-analysis-ui-config
              mountPath: {{ .Values.config.cbasUI.conf_dir }}/{{ .Values.config.cbasUI.conf_file }}
              subPath: {{ .Values.config.cbasUI.conf_file }}

{{- end -}}
{{- define "cbas-libchart.cbas-ui-deploy" -}}
{{- include "cbas-libchart.util.merge" (append . "cbas-libchart.cbas-ui-deploy.tpl") -}}
{{- end -}}