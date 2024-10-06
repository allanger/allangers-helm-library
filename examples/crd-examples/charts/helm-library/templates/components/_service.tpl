{{/*
	* This component should make it easier to create pvc
*/}}
{{- define "lib.component.service" }}
{{- range $k, $v := .Values.services }}
{{- $customName := printf "%s-%s" (include "chart.fullname" $) $k }}
{{- if $v.enabled }} {{- /* if[0] */}}
{{- 
	$metadata := include "lib.helpers.metadata" 
	(dict "Context" $ "customName" $customName "annotations" $v.annotations) 
}}
{{ $spec := $v }}
{{- if not $spec.type -}}
{{- set $spec "type" "ClusterIP" -}}
{{- end }}
{{ 
  include "lib.core.service"
  (dict "metadata" $metadata "ctx" $ "spec" $spec)
}}
{{- end }}
{{- end }}
{{- end }}
