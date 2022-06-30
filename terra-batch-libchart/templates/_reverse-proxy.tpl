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


{{- define "terra-batch-libchart.reverse-proxy-config.tpl" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "app.fullname" . }}-reverse-proxy-config
data:
  {{ .Values.config.proxy.conf_file }}: |-
    daemon off;

    events {
      worker_connections 1024;
    }
    http {
      server {
        listen 8000;

        location / {
          proxy_pass http://{{ include "app.fullname" . }}-batch-analysis-ui-svc:8080/;
        }

        # For now, keep serving 'cromwell' APIs at proxy root, but we should consider this deprecated and
        # update clients to use `/cromwell/` when talking to the Cromwell APIs.
        location /api/ {
          proxy_pass http://{{ include "app.fullname" . }}-cromwell-svc:8000/api/;
        }
        location /engine/ {
          proxy_pass http://{{ include "app.fullname" . }}-cromwell-svc:8000/engine/;
        }

        # Reference to ngingx's local content
        location /index.html {
          alias /www/data/index.html;
        }

        # Proxying to other hosts by subpath:
        location /cbas/ {
          proxy_pass http://{{ include "app.fullname" . }}-cbas-svc:8080/;
        }
        location /cromwell/ {
          proxy_pass http://{{ include "app.fullname" . }}-cromwell-svc:8000/;
        }
      }
    }
  {{ .Values.config.proxy.www_file }}: |-
    <!doctype html>
    <html>
      <head>
        <title>Hello nginx</title>
        <meta charset="utf-8" />
      </head>
      <body>
        <h1>
          Cromwell as an App Proxy
        </h1>
        <p> Now serving from the terra-batch-libchart Library Chart! </p>
        <p> This is the Cromwell as an App proxy. Valid internal paths:</p>
        <ul>
          <li> Batch Analysis UI: <a href="./"> batch-analysis-ui/ </a> </li>
          <li> CBAS: /cbas/
          <ul>
            <li> eg: <a href="./cbas/swagger-ui.html"> cbas/swagger-ui.html </a> </li>
            <li> eg: <a href="./cbas/status"> cbas/status </a> </li>
          </ul>
          </li>
          <li> Cromwell: <a href="./cromwell/"> cromwell/ </a> </li>
          <ul>
            <li> eg: <a href="./engine/v1/version"> engine/v1/version </a> </li>
          </ul>
        </ul>
      </body>
    </html>
{{- end -}}
{{- define "terra-batch-libchart.reverse-proxy-config" -}}
{{- include "terra-batch-libchart.util.merge" (append . "terra-batch-libchart.reverse-proxy-config.tpl") -}}
{{- end -}}