{{- define "coa-helm.labels" -}}
leoAppName: {{ .Values.persistence.leoAppInstanceName }}
workspaceId: {{ .Values.persistence.workspaceManager.workspaceId }}
{{- if .Values.workloadIdentity.enabled }}
azure.workload.identity/use: "true"
{{- else }}
aadpodidbinding: {{ .Values.identity.name }}
{{- end }}
{{- end -}}
