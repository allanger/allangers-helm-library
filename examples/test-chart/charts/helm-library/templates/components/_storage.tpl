{{/*
	* This component should make it easier to create pvc
*/}}
{{- define "lib.component.storage" -}}
{{- range $k, $v := .Values.storage }}
{{- $customName := printf "%s-%s" (include "chart.fullname" $) $k }}
{{- if $v.enabled }} {{- /* if[0] */}}
{{- 
	$metadata := include "lib.helpers.metadata" 
	(dict "Context" $ "customName" $customName "annotations" $v.annotations) 
}}
{{ include "lib.core.pvc" (dict "Context" $ "metadata" $metadata "spec" $v) }}
{{- end }} {{- /* /if[0] */}}
{{- end }}
{{- end -}}
