{{/*
	* This component should make it easier to create pvc
*/}}
{{- define "lib.component.storage" -}}
{{- range $k, $v := .Values.storage }}
{{- $customName := include "lib.component.storage.name" (dict "ctx" $.ctx "name" $k) }}
{{- if $v.enabled }} {{- /* if[0] */}}
{{- 
	$metadata := include "lib.helpers.metadata" 
	(dict "Context" $ "customName" $customName "annotations" $v.annotations) 
}}
{{ include "lib.core.pvc" (dict "Context" $ "metadata" $metadata "spec" $v) }}
{{- end }} {{- /* /if[0] */}}
{{- end }}
{{- end -}}

{{- define "lib.component.storage.name" -}} {{- /* define[0] */ -}}
{{- include "lib.error.noCtx" . -}}
{{- include "lib.error.noKey" (dict "ctx" . "key" "name") -}}
{{ printf "%s-%s-storage" .ctx.Release.Name .name }}
{{- end -}} {{- /* /define[0] */ -}}
