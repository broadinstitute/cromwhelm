{{/*
Expand the name of the chart.
*/}}
{{- define "app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" | lower }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "app.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" | lower }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" | lower }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" | lower }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "app.labels" -}}
helm.sh/chart: {{ include "app.chart" . }}
{{ include "app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Cromwell API labels
*/}}
{{- define "app.cromwell.selectorLabels" -}}
app.kubernetes.io/component: {{ .Values.cromwell.name }}
{{- end}}

{{/*
CBAS Service labels
*/}}
{{- define "app.cbas.selectorLabels" -}}
app.kubernetes.io/component: {{ .Values.cbas.name }}
{{- end}}

{{/*
Return postgres database user password.
Lookup the existing secret values if they exist, or generate a random value
*/}}
{{- define "dbPassword" -}}
{{- if .Values.postgres.password }}
    {{- .Values.postgres.password -}}
{{- else }}
    {{- $randomValue := (randAlphaNum 32) -}}
    {{- $generatedValue := (set .Values.postgres "password" $randomValue) -}}
    {{- .Values.postgres.password -}}
{{- end }}
{{- end }}

{{- define "useLZPostgresWithPgBouncer" -}}
{{- if and (.Values.postgres.pgbouncer.enabled) (not (.Values.postgres.podLocalDatabaseEnabled)) -}}
true
{{- else -}}
false
{{- end }}
{{- end -}}

{{/*
Return the port to use to connect to postgresql. Allows pgbouncer port to override 
standard port when appropriate. Non-Azure apps should always use the standard port.
*/}}
{{- define "postgresPort" -}}
{{- if (eq ("true") (include "useLZPostgresWithPgBouncer" .)) }}
{{- .Values.postgres.pgbouncer.port }}
{{- else }}
{{- .Values.postgres.port }}
{{- end }}
{{- end -}}

{{/*
We want Cromwell and CBAS to use pod-local postgres unless PgBouncer is enabled. 
*/}}
{{- define "podLocalDatabaseEnabledForCromwellCBAS" -}}
{{- if eq ("true") (include "useLZPostgresWithPgBouncer" .) -}}
false
{{- else -}}
true
{{- end }}
{{- end -}}

{{/*
Build a postgres pod into the app if any service needs it.
*/}}
{{- define "buildPodLocalDatabase" -}}
{{- if or (eq ("true") (include "podLocalDatabaseEnabledForCromwellCBAS" .)) (.Values.postgres.podLocalDatabaseEnabledForTES) -}}
true
{{- else -}}
false
{{- end }}
{{- end -}}
