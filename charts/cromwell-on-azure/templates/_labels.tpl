{{- define "coa-helm.labels" -}}
aadpodidbinding: {{ .Values.identity.name }}
leoAppName: {{ .Values.persistence.leoAppInstanceName }}
workspaceId: {{ .Values.persistence.workspaceManager.workspaceId }}
{{- end -}}