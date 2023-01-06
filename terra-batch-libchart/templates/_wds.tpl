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
              mountPath: {{ .Values.wds.conf_dir }}/{{ .Values.wds.conf_file }}
              subPath: {{ .Values.wds.conf_file }}
          env:
            - name: SPRING_CONFIG_ADDITIONAL-LOCATION
              value: {{ .Values.wds.conf_dir }}/{{ .Values.wds.conf_file }}
            - name: WDS_DB_HOST
              value: {{ include "app.fullname" . }}-postgres
            - name: WDS_DB_PASSWORD
              value: {{ include "dbPassword" . | b64enc | quote }}
            - name: WDS_DB_USER
              value: {{ .Values.postgres.user }}
            - name: WDS_DB_NAME
              value: {{ .Values.postgres.wds.dbname }}
            - name: WDS_DB_PORT
              value: "{{ .Values.postgres.port }}"
            - name: SWAGGER_BASE_PATH
              value: "{{ .Values.env.swaggerBasePath }}"
            - name: WORKSPACE_ID
              value: "{{ .Values..persistence.workspaceManager.workspaceId }}"

      volumes:
        - name: {{ include "app.fullname" . }}-wds-config
          configMap:
            name: {{ include "app.fullname" . }}-wds-config
            items:
              - key: {{ .Values.wds.conf_file }}
                path: {{ .Values.wds.conf_file }}
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


{{- define "terra-batch-libchart.wds-config.tpl" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "app.fullname" . }}-wds-config
data:
  {{ .Values.wds.conf_file }}: |-
    # Config overrides go here

{{- end -}}
{{- define "terra-batch-libchart.wds-config" -}}
{{- include "terra-batch-libchart.util.merge" (append . "terra-batch-libchart.wds-config.tpl") -}}
{{- end -}}
