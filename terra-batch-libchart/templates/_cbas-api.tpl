{{- define "terra-batch-libchart.cbas-api-deploy.tpl" -}}
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
          image: {{ .Values.cbas.image }}
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
{{- define "terra-batch-libchart.cbas-api-deploy" -}}
{{- include "terra-batch-libchart.util.merge" (append . "terra-batch-libchart.cbas-api-deploy.tpl") -}}
{{- end -}}


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


{{- define "terra-batch-libchart.cbas-api-config.tpl" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "app.fullname" . }}-cbas-config
data:
  {{ .Values.config.cbas.conf_file }}: |-
    workflow-engines:
      cromwell:
        baseUri: "http://{{ include "app.fullname" . }}-cromwell-svc:8000"
        healthUri: "http://{{ include "app.fullname" . }}-cromwell-svc:8000/engine/v1/status"

{{- end -}}
{{- define "terra-batch-libchart.cbas-api-config" -}}
{{- include "terra-batch-libchart.util.merge" (append . "terra-batch-libchart.cbas-api-config.tpl") -}}
{{- end -}}
