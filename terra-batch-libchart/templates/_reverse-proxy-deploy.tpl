{{- define "terra-batch-libchart.reverse-proxy-deploy.tpl" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "app.fullname" . }}-reverse-proxy-deploy
  labels:
  {{- include "app.labels" . | nindent 4 }}
spec:
  replicas: 1
  selector:
    matchLabels:
  {{- include "app.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
    {{- include "app.selectorLabels" . | nindent 8 }}
    spec:
      volumes:
        - name: {{ include "app.fullname" . }}-reverse-proxy-config
          configMap:
            name: {{ include "app.fullname" . }}-reverse-proxy-config
            items:
              - key: {{ .Values.config.proxy.conf_file }}
                path: {{ .Values.config.proxy.conf_file }}
              - key: {{ .Values.config.proxy.www_file }}
                path: {{ .Values.config.proxy.www_file }}
      containers:
        - name: reverse-proxy-container
          image: nginx:latest
          imagePullPolicy: Always
          ports:
            - containerPort: 8000
          volumeMounts:
            - name: {{ include "app.fullname" . }}-reverse-proxy-config
              mountPath: {{ .Values.config.proxy.conf_dir }}/{{ .Values.config.proxy.conf_file }}
              subPath: {{ .Values.config.proxy.conf_file }}
            - name: {{ include "app.fullname" . }}-reverse-proxy-config
              mountPath: {{ .Values.config.proxy.www_dir }}/{{ .Values.config.proxy.www_file }}
              subPath: {{ .Values.config.proxy.www_file }}

          command: ["nginx"]
{{- end -}}
{{- define "terra-batch-libchart.reverse-proxy-deploy" -}}
{{- include "terra-batch-libchart.util.merge" (append . "terra-batch-libchart.reverse-proxy-deploy.tpl") -}}
{{- end -}}