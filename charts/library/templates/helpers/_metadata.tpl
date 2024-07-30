{{/* 
	* Metadata should accept a dict 
*/}}
{{- define "lib.helpers.metadata" -}} {{- /* define[0] */ -}}
{{- if .customname -}} {{- /* if[0] */ -}}
name: {{ .customname }}
{{- else -}}
name: {{ include "chart.fullname" .Context }}
{{- end }} {{- /* /if[0] */}}
labels:
	{{- include "lib.helpers.labels" .Context | nindent 2 }}
{{- if .annotations }} {{- /* if[0] */}}
annotations:
	{{- .annotations | toYaml | nindent 2 }}
{{- end }} {{- /* /if[0] */}}
{{- end }} {{- /* /define[0] */ -}}

{{/*
	* Common labels
*/}}
{{- define "lib.helpers.labels" -}}
helm.sh/chart: {{ include "chart.chart" . }}
{{ include "lib.helpers.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
	* Selector labels
*/}}
{{- define "lib.helpers.selectorLabels" -}}
app.kubernetes.io/name: {{ include "chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
