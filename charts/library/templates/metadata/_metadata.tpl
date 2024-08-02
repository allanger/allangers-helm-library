{{/* 
	* Metadata is accepting a dict as an argument
	* dict should contain the following keys:
	* 	- ctx
	* 	- name (optional)
	*   - labels
	*		- annotations (optional)
*/}}
{{- define "lib.metadata" -}} {{- /* define[0] */ -}}
{{- include "lib.error.noCtx" . -}}
{{- include "lib.error.noKey" (dict "ctx" . "key" "labels") -}}
{{- if .name -}} {{- /* if[1] */ -}}
name: {{ .name }}
{{- else -}}
name: {{ include "chart.fullname" .ctx }}
{{- end }} {{- /* /if[1] */}}
labels:
{{ .labels | indent 2 }}
{{- if .annotations }} {{- /* if[1] */}}
annotations:
	{{- .annotations | toYaml | nindent 2 }}
{{- end }} {{- /* /if[1] */}}
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
{{- with .global -}} {{- /* /if[1] */ -}}
{{ toYaml . }}
{{- end }} {{- /* /if[1] */}}
{{ with .local -}} {{- /* /if[1] */ -}}
{{ toYaml . }}
{{- end }} {{- /* /if[1] */}}
{{ include "lib.chart.labels" (dict "ctx" .ctx) }}
{{- end -}} {{- /* /define[0] */ -}}

