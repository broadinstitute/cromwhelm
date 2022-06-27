{{- define "app.additionalName" -}}
{{- default "blargo" .Values.nameOverride | trunc 63 | trimSuffix "-" | lower }}
{{- end }}