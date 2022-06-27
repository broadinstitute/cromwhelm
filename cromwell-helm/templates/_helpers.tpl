{{/*
Return postgres database user password.
Lookup the existing secret values if they exist, or generate a random value
*/}}
{{- define "dbPassword" -}}
{{- if .Values.db.password }}
    {{- .Values.db.password -}}
{{- else }}
    {{- $randomValue := (randAlphaNum 32) -}}
    {{- $generatedValue := (set .Values.db "password" $randomValue) -}}
    {{- .Values.db.password -}}
{{- end }}
{{- end }}
