{{/* 
	* Metadata is accepting a dict as an argument
	* dict should contain the following keys:
	* 	- ctx
	* 	- name (optional)
	*   - labels (optional)
	*		- annotations (optional)
*/}}
{{- define "lib.metadata" -}} {{- /* define[0] */ -}}
{{- include "lib.error.noCtx" . -}}
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
	* Merge global helm labels with custom ones
	* accepts:
	* ctx
	* global (optional) - Labels that are defined for 
	*												all resources
	* local  (optional) - Labels that are define only for 
	*                       the current resource
*/}}
{{- define "lib.metadata.mergeLabels" -}} {{- /* /define[0] */ -}}
{{- include "lib.error.noCtx" . -}}
{{- include "lib.core.metadata.labels" (dict "ctx" .ctx) }}
{{- end -}} {{- /* /define[0] */ -}}

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
