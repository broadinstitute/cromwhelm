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
      annotations:
        checksum/config: {{ include ("terra-batch-libchart.reverse-proxy-config.tpl") . | sha256sum }}
      labels:
    {{- include "app.selectorLabels" . | nindent 8 }}
    spec:
      volumes:
        - name: {{ include "app.fullname" . }}-reverse-proxy-config
          configMap:
            name: {{ include "app.fullname" . }}-reverse-proxy-config
            items:
              - key: {{ .Values.proxy.conf_file }}
                path: {{ .Values.proxy.conf_file }}
              - key: {{ .Values.proxy.www_file }}
                path: {{ .Values.proxy.www_file }}
      containers:
        - name: reverse-proxy-container
          image: {{ .Values.proxy.image }}
          imagePullPolicy: Always
          ports:
            - containerPort: 8000
          volumeMounts:
            - name: {{ include "app.fullname" . }}-reverse-proxy-config
              mountPath: {{ .Values.proxy.conf_dir }}/{{ .Values.proxy.conf_file }}
              subPath: {{ .Values.proxy.conf_file }}
            - name: {{ include "app.fullname" . }}-reverse-proxy-config
              mountPath: {{ .Values.proxy.www_dir }}/{{ .Values.proxy.www_file }}
              subPath: {{ .Values.proxy.www_file }}

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
  type: {{ .Values.proxy.type }}
  selector:
    {{- include "app.selectorLabels" . | nindent 4 }}
  ports:
    - port: {{ .Values.proxy.port }}
      targetPort: {{ .Values.proxy.port }}
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
  {{ .Values.proxy.conf_file }}: |-
    daemon off;

    events {
      worker_connections 1024;
    }
    http {
      server {
        access_log /dev/stdout combined;
        listen 8000;

        # Reference to nginx's local content
        location / {
          alias /www/data/;
        }

        # Proxying to other hosts by subpath:
        {{- if .Values.cromwell.enabled }}
        # For now, keep serving 'cromwell' APIs at proxy root, but we should consider this deprecated and
        # update clients to use `/cromwell/` when talking to the Cromwell APIs.
        location /api/ {
          proxy_pass http://{{ include "app.fullname" . }}-cromwell-svc:8000/api/;
        }
        location /cromwell/ {
          proxy_pass http://{{ include "app.fullname" . }}-cromwell-svc:8000/;
        }
        location /engine/ {
          proxy_pass http://{{ include "app.fullname" . }}-cromwell-svc:8000/engine/;
        }
        {{ end }}

        {{- if .Values.cbas.enabled }}
        location /cbas/ {
          proxy_pass http://{{ include "app.fullname" . }}-cbas-svc:8080/;
        }
        {{ end }}
      }
    }
  {{ .Values.proxy.www_file }}: |-
    <!doctype html>
    <html>
      <head>
        <title>Hello nginx</title>
        <meta charset="utf-8" />
      </head>
      <body>
        <h1>
          Cromwell as an App Proxy.
        </h1>
        <p> This is the Cromwell as an App proxy. Valid internal paths:</p>
        <ul>
          <li> CBAS: /cbas/
          <ul>
            <li> eg: <a href="./cbas/swagger-ui.html"> cbas/swagger-ui.html </a> </li>
            <li> eg: <a href="./cbas/status"> cbas/status </a> </li>
          </ul>
          </li>
          <li> Cromwell: <a href="./cromwell/"> cromwell/ </a> </li>
          <ul>
            <li> eg: <a href="./cromwell/engine/v1/version"> cromwell/engine/v1/version </a> </li>
          </ul>
        </ul>
      </body>
    </html>
{{- end -}}
{{- define "terra-batch-libchart.reverse-proxy-config" -}}
{{- include "terra-batch-libchart.util.merge" (append . "terra-batch-libchart.reverse-proxy-config.tpl") -}}
{{- end -}}
