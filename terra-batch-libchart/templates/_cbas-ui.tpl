{{- define "terra-batch-libchart.cbas-ui-deploy.tpl" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "app.fullname" . }}-cbas-ui-depl
  labels:
    {{- include "app.labels" . | nindent 4 }}
spec:
  replicas: 1
  selector:
    matchLabels:
      {{- include "app.cbasUI.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "app.cbasUI.selectorLabels" . | nindent 8 }}
        leoServiceName: cbas-ui
    spec:
      hostname: {{ .Values.cbasUI.name }}
      volumes:
        - name: {{ include "app.fullname" . }}-cbas-ui-config
          configMap:
            name: {{ include "app.fullname" . }}-cbas-ui-config
            items:
              - key: {{ .Values.cbasUI.conf_file }}
                path: {{ .Values.cbasUI.conf_file }}
      containers:
        - name: {{ .Values.cbasUI.name }}-container
          image: {{ .Values.cbasUI.image }}
          imagePullPolicy: Always
          ports:
            - containerPort: 8080
          volumeMounts:
            - name: {{ include "app.fullname" . }}-cbas-ui-config
              mountPath: {{ .Values.cbasUI.conf_dir }}/{{ .Values.cbasUI.conf_file }}
              subPath: {{ .Values.cbasUI.conf_file }}

{{- end -}}
{{- define "terra-batch-libchart.cbas-ui-deploy" -}}
{{- include "terra-batch-libchart.util.merge" (append . "terra-batch-libchart.cbas-ui-deploy.tpl") -}}
{{- end -}}


{{- define "terra-batch-libchart.cbas-ui-service.tpl" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "app.fullname" . }}-cbas-ui-svc
  labels:
  {{- include "app.labels" . | nindent 4 }}
spec:
  selector:
  {{- include "app.cbasUI.selectorLabels" . | nindent 4 }}
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
  name: {{ include "app.fullname" . }}-cbas-ui-config
{{- end -}}
{{- define "terra-batch-libchart.cbas-ui-config" -}}
{{- include "terra-batch-libchart.util.merge" (append . "terra-batch-libchart.cbas-ui-config.tpl") -}}
{{- end -}}
