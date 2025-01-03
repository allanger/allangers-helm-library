{{/* 
	* Metadata is accepting a dict as an argument
	* dict should contain the following keys:
	* 	- ctx
	* 	- name (optional)
	*   - labels (optional)
	*		- annotations (optional)
*/}}
{{- define "lib.core.metadata" -}} {{- /* define[0] */ -}}
{{- if .name -}} {{- /* if[0] */ -}}
name: {{ .name }}
{{- else -}}
name: {{ include "chart.fullname" .ctx }}
{{- end }} {{- /* /if[0] */}}
labels:
	{{- include "lib.helpers.labels" .ctx | nindent 2 }}
{{- if .annotations }} {{- /* if[0] */}}
annotations:
	{{- .annotations | toYaml | nindent 2 }}
{{- end }} {{- /* /if[0] */}}
{{- end }} {{- /* /define[0] */ -}}

{{/*
	* Common labels
*/}}
{{- define "lib.core.metadata.labels" -}}
helm.sh/chart: {{ include "chart.chart" .ctx }}
{{ include "lib.helpers.selectorLabels"  }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
	* Selector labels
*/}}
{{- define "lib.helpers.metadata.selectorLabels" -}}
app.kubernetes.io/name: {{ include "chart.name" .ctx }}
app.kubernetes.io/instance: {{ .ctx.Release.Name }}
{{- end }}
