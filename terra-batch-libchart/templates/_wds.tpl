{{- define "terra-batch-libchart.wds-deploy.tpl" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "app.fullname" . }}-wds-depl
  labels:
    {{- include "app.labels" . | nindent 4 }}
spec:
  replicas: 1
  selector:
    matchLabels:
      {{- include "app.wds.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "app.wds.selectorLabels" . | nindent 8 }}
    spec:
      containers:
        - name: {{ .Values.wds.name }}-container
          image: {{ .Values.wds.image }}
          imagePullPolicy: Always
          ports:
            - containerPort: 8080
          volumeMounts:
            - name: {{ include "app.fullname" . }}-wds-config
              mountPath: {{ .Values.config.wds.conf_dir }}/{{ .Values.config.wds.conf_file }}
              subPath: {{ .Values.config.wds.conf_file }}
          env:
            - name: SPRING_CONFIG_LOCATION
              value: {{ .Values.config.wds.conf_dir }}/{{ .Values.config.wds.conf_file }}
      volumes:
        - name: {{ include "app.fullname" . }}-wds-config
          configMap:
            name: {{ include "app.fullname" . }}-wds-config
            items:
              - key: {{ .Values.config.wds.conf_file }}
                path: {{ .Values.config.wds.conf_file }}
{{- end -}}
{{- define "terra-batch-libchart.wds-deploy" -}}
{{- include "terra-batch-libchart.util.merge" (append . "terra-batch-libchart.wds-deploy.tpl") -}}
{{- end -}}


{{- define "terra-batch-libchart.wds-service.tpl" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "app.fullname" . }}-wds-svc
  labels:
  {{- include "app.labels" . | nindent 4 }}
spec:
  selector:
  {{- include "app.wds.selectorLabels" . | nindent 4 }}
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
{{- end -}}
{{- define "terra-batch-libchart.wds-service" -}}
{{- include "terra-batch-libchart.util.merge" (append . "terra-batch-libchart.wds-service.tpl") -}}
{{- end -}}
