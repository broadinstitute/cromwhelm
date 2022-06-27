{{- define "cbas-libchart.cbas-api-deploy.tpl" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "app.fullname" . }}-cbas-depl
  labels:
    {{- include "app.labels" . | nindent 4 }}
spec:
  replicas: 1
  selector:
    matchLabels:
      {{- include "app.cbas.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "app.cbas.selectorLabels" . | nindent 8 }}
    spec:
      containers:
        - name: {{ .Values.cbas.name }}-container
          image: us.gcr.io/broad-dsp-gcr-public/composite-batch-analysis-service:0.0.5
          imagePullPolicy: Always
          ports:
            - containerPort: 8080
          volumeMounts:
            - name: {{ include "app.fullname" . }}-cbas-config
              mountPath: {{ .Values.config.cbas.conf_dir }}/{{ .Values.config.cbas.conf_file }}
              subPath: {{ .Values.config.cbas.conf_file }}
          env:
            - name: SPRING_CONFIG_LOCATION
              value: {{ .Values.config.cbas.conf_dir }}/{{ .Values.config.cbas.conf_file }}
      volumes:
        - name: {{ include "app.fullname" . }}-cbas-config
          configMap:
            name: {{ include "app.fullname" . }}-cbas-config
            items:
              - key: {{ .Values.config.cbas.conf_file }}
                path: {{ .Values.config.cbas.conf_file }}
{{- end -}}
{{- define "cbas-libchart.cbas-api-deploy" -}}
{{- include "cbas-libchart.util.merge" (append . "cbas-libchart.cbas-api-deploy.tpl") -}}
{{- end -}}