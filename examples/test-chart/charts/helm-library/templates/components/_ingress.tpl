{{- define "lib.component.ingress" }}
{{- range $k, $v := .Values.ingress }}
{{- $customName := printf "%s-%s" (include "chart.fullname" $) $k }}
{{- if $v.enabled }} {{- /* if[0] */}}
{{- 
	$metadata := include "lib.helpers.metadata" 
	(dict "Context" $ "customName" $customName "annotations" $v.annotations) 
}}
{{- $spec := $v -}}
{{- $_ := unset $spec "enabled" -}}
{{ include "lib.core.ingress" (dict "Context" $ "metadata" $metadata "spec" $spec ) }}
{{- end }}
{{- end }}
{{- end }}
