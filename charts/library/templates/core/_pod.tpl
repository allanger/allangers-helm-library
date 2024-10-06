{{- define "lib.core.pod" -}} {{- /* define[0] */ -}}
{{- fail "pods are not implemented net" -}}
{{- end -}} {{- /* /define[0] */ -}}

{{/* 
  * This function should accept a seucrityContext
  * from values, so please use it with values
  * directly
  * SecurityContext is not templated, so it will be 
  * added as is
*/}}
{{- define "lib.core.pod.securityContext" -}} {{- /* define[0] */ -}}
securityContext:
{{- if not .securityContext }} {{- /* if[1] */}}
# ---------------------------------------------------------------------
# Using the default security context, if it doesn't work for you,
# please update `.Values.base.workload.securityContext`
# ---------------------------------------------------------------------
  runAsUser: 1000
  runAsGroup: 3000
  fsGroup: 2000
  seccompProfile:
    type: RuntimeDefault
{{- else -}}
{{- with .securityContext }} {{- /* with[2] */}}
{{ toYaml . | indent 2 }}
{{- end -}} {{- /* /with[2] */}}
{{- end -}} {{- /* /if[1] */ -}}
{{- end -}} {{- /* define[0] */ -}}


{{- define "lib.core.pod.volumes" -}} {{- /* define[0] */ -}}
{{- if or ( or .ctx.Values.storage .ctx.Values.extraVolumes) .ctx.Values.files -}} {{- /* if[0]*/ -}}
volumes:
  {{- /* If storage is defined, mount a pvc */ -}}
  {{- if .ctx.Values.storage }} {{- /* if[1] */}}
    {{- range $k, $v := .ctx.Values.storage }} {{- /* range[0] */}}
    {{- if $v.enabled }}
  - name: {{ $k }}-storage
    persistentVolumeClaim:
      claimName: "{{ printf "%s-%s" (include "chart.fullname" $.ctx) $k }}"
    {{- end }}
    {{- end }} {{- /* /range[0] */}}
  {{- end  }} {{- /* /if[1] */}}
  {{- if .ctx.Values.extraVolumes}} {{- /* if[1] */}}
    {{- range $k, $v := .ctx.Values.extraVolumes}} {{- /* range[0] */}}
  - name: {{ $k }}-extra
    {{- $v | toYaml | nindent 4 }}
    {{- end }} {{- /* /range[0] */}}
  {{- end }} {{- /* /if[1] */}}
  {{- if .ctx.Values.files }} {{- /* if[1] */}}
    {{- range $k, $v := .ctx.Values.files }} {{- /* range[0] */}}
  - name: {{ $k }}-file
      {{- if $v.sensitive }} {{- /* if[2] */}}
    secret:
      defaultMode: 420
      secretName: "{{- printf "%s-%s" (include "chart.fullname" $.ctx) $k }}"
      {{- else }}
    configMap:
      name: "{{- printf "%s-%s" (include "chart.fullname" $.ctx) $k }}"
      {{- end }} {{- /* /if[2] */}}
    {{- end }} {{- /* /range[0] */}}
  {{- end }} {{- /* /if[1] */}}
{{- end -}} {{- /* /if[0] */ -}}
{{- end -}} {{- /* define[0] */ -}}

{{/*
  * This template should generate a valid container
  * defintion that should be used by both
  * containers and initContainers
*/}}

{{- define "lib.core.pod.containers" -}} {{- /* define[0] */ -}}
{{- include "lib.error.noCtx" . -}}
{{- include "lib.error.noKey" (dict "ctx" . "key" "containers") -}}
{{- $ctx := .ctx }}
containers:
{{- $containers := list }}
{{- range $k, $v := .containers }} {{- /* range[1] */}}
{{- $containerRaw := include "lib.core.pod.container" 
    (dict 
      "ctx" $ctx
      "name" $k 
      "data" $v
    )
}}
{{- $container := fromYaml $containerRaw }}
{{- if hasKey $container "Error" }} {{- /* if[2] */}}
{{- fail (printf "%s\n%v" $container $containerRaw) }}
{{- end }} {{- /* /if[1] */}}
{{- $containers = append $containers $container }}
{{- end }} {{- /* /range[1] */}}
{{ $containers | toYaml | indent 2 }}
{{- end -}} {{- /* define[0] */ -}}

{{- define "lib.core.pod.initContainers" -}} {{- /* define[0] */ -}}
{{- end -}} {{- /* define[0] */ -}}

{{- define "lib.core.pod.container.image.tag" -}} {{/* define[0] */}}
{{- if or .tag .appVersion -}} {{/* if[1] */}}
  {{- if .tag -}} {{/* if[2] */}}
    {{- .tag -}} 
  {{- else -}}
    {{- .appVersion  -}}
  {{- end -}} {{/* /if[2] */}}
{{- else -}}
  {{ fail ".tag or .appVersion must be passed to this helper"}}
{{- end -}} {{/* /if[1] */}}
{{- end -}} {{/* /define[0] */}}


