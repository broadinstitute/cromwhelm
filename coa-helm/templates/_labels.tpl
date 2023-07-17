{{- define "coa-helm.labels" -}}
aadpodidbinding: {{ .Values.identity.name }}
leoAppName: {{ .Values.persistence.leoAppInstanceName }}
workspaceId: {{ .Values.persistence.workspaceManager.workspaceId }}
{{- if .Values.workloadIdentity.enabled }}
azure.workload.identity/use: "true"
{{- end }}
{{- end -}}
