{{/*
	* Expand the name of the chart.
*/}}
{{- define "lib.chart.release" -}} {{- /* define[0] */}}
{{- if not .ctx -}}{{- fail "no context provided" -}}{{- end -}}
{{- default .ctx.Chart.Name .ctx.Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }} {{- /*/define[0] */}}

{{/*
	* Create chart name and version as used by the chart label.
*/}}
{{- define "lib.chart.chart" -}} {{- /* define[0] */}}
{{- if not .ctx -}}{{- fail "no context provided" -}}{{- end -}}
{{- printf "%s-%s" .ctx.Chart.Name .ctx.Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }} {{- /*/define[0] */}}

{{/*
	* Common labels
*/}}
{{- define "lib.chart.labels" -}} {{- /* define[0] */}}
{{- if not .ctx -}}{{- fail "no context provided" -}}{{- end -}}
helm.sh/chart: {{ include "lib.chart.chart" (dict "ctx" .ctx) }}
{{ include "lib.chart.selectorLabels" (dict "ctx" .ctx) }}
{{- if .ctx.Chart.AppVersion }} {{- /* if[1] */}}
app.kubernetes.io/version: {{ .ctx.Chart.AppVersion | quote }}
{{- end }} {{- /* /if[1] */}}
app.kubernetes.io/managed-by: {{ .ctx.Release.Service }}
{{- end }} {{- /*/define[0] */}}

{{/*
	* Selector labels
*/}}
{{- define "lib.chart.selectorLabels" -}} {{- /* define[0] */}}
{{- if not .ctx -}}{{- fail "no context provided" -}}{{- end -}}
app.kubernetes.io/name: {{ include "lib.chart.release" (dict "ctx" .ctx) }}
app.kubernetes.io/instance: {{ .ctx.Release.Name }}
{{- end }} {{- /*/define[0] */}}

