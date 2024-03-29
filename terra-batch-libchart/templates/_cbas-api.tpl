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
        leoServiceName: cbas
    spec:
      containers:
        - name: {{ .Values.cbas.name }}-container
          image: {{ .Values.cbas.image }}
          imagePullPolicy: Always
          ports:
            - containerPort: 8080
          resources:
            requests:
              memory: "256Mi"
              cpu: "50m"
            limits:
              memory: "1024Mi"
              cpu: "200m"
          volumeMounts:
            - name: {{ include "app.fullname" . }}-cbas-config
              mountPath: {{ .Values.cbas.conf_dir }}/{{ .Values.cbas.conf_file }}
              subPath: {{ .Values.cbas.conf_file }}
          env:
            - name: SPRING_CONFIG_ADDITIONAL-LOCATION
              value: {{ .Values.cbas.conf_dir }}/{{ .Values.cbas.conf_file }}
            - name: APPLICATIONINSIGHTS_CONNECTION_STRING
              value: {{ .Values.config.applicationInsightsConnectionString }}
          livenessProbe:
            httpGet:
              path: /status
              port: 8080
            initialDelaySeconds: 120
            periodSeconds: 60
      volumes:
        - name: {{ include "app.fullname" . }}-cbas-config
          configMap:
            name: {{ include "app.fullname" . }}-cbas-config
            items:
              - key: {{ .Values.cbas.conf_file }}
                path: {{ .Values.cbas.conf_file }}
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
{{- end -}}
{{- define "terra-batch-libchart.cbas-api-config" -}}
{{- include "terra-batch-libchart.util.merge" (append . "terra-batch-libchart.cbas-api-config.tpl") -}}
{{- end -}}
