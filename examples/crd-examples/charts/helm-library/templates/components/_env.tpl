{{/*
	* This component should make it easier to create sets
	* of environment variables via configmaps and secrets
*/}}
{{- define "lib.component.env" -}} {{- /* define[0] */ -}}
{{- range $k, $v := .Values.env }} {{- /* range[0] */}}
{{- $customName := printf "%s-%s" (include "chart.fullname" $) $k }}
{{- if $v.enabled }} {{- /* if[0] */}}
{{- 
	$metadata := include "lib.helpers.metadata" 
	(dict "Context" $ "customName" $customName "annotations" $v.annotations) 
}}
{{- $data := dict -}}
{{- range $key, $value := $v.data }} {{- /* range[1] */}}
{{- if not (has $key ($v.remove)) }} {{- /* if[1] */}}
{{- $_ := set $data $key (tpl (toString $value) $) }}
{{- end }} {{- /* /if[1] */}}
{{- end }} {{- /* /range[1] */}}
{{- if $v.sensitive }} {{- /* if[1] */}}
{{ include "lib.core.secret" (dict "Context" $ "metadata" $metadata "data" $data) }}
{{- else }}
{{ include "lib.core.configmap" (dict "Context" $ "metadata" $metadata "data" $data) }}
{{- end -}} {{- /* /if[1] */}}
{{- end }} {{- /* /if[0] */}}
{{- end }} {{- /* /range[0] */}}
{{- end -}} {{- /* /define[0] */ -}}
