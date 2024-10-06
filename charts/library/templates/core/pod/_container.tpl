{{/*
   * This template should be able to create a valid container spec
*/}}
{{- define "lib.core.pod.container" -}} {{- /* define[0] */ -}}
{{- include "lib.error.noKey" (dict "ctx" . "key" "data") -}}
{{- include "lib.error.noKey" (dict "ctx" . "key" "name") -}}
name: {{ .name }}
{{ include "lib.core.pod.container.securityContext" (dict "securityContext" .data.securityContext) }}
{{ include "lib.core.pod.container.command" (dict "command" .data.command) }}
{{ include "lib.core.pod.container.args" (dict "args" .data.command) }}
{{ include "lib.core.pod.container.livenessProbe" (dict "ctx" .ctx "probe" .data.livenessProbe) }}
{{ include "lib.core.pod.container.readinessProbe" (dict "ctx" .ctx"probe" .data.readinessProbe) }}
{{- /*
  {{- 
    include "lib.core.pod.container.image" 
    (dict 
      "chart" .ctx.Chart 
      "image" .data.image
    ) 
    | nindent 2 
  -}}
{{- include "lib.core.pod.container.args" .ContainerData | indent 2 -}} 
{{-
  include "lib.core.pod.container.ports" 
    (dict "Context" .Context "Container" .ContainerData) 
    | indent 2 
-}}
{{- 
  include "lib.core.pod.container.volumeMounts" 
    .ContainerData | indent 2 
-}}
{{- 
    include "lib.core.pod.container.envFrom" 
    (dict "Context" .Context "Container" .ContainerData) 
    | indent 2 
-}}
{{- 
    include "lib.core.pod.container.livenessProbe" 
    .ContainerData 
    | indent 2 
-}}
{{- 
    include "lib.core.pod.container.readinessProbe" 
    .ContainerData | indent 2 
-}}
{{- 
    include "lib.core.pod.container.startupProbe" 
    .ContainerData | indent 2 
-}}
*/}}
{{- end -}} {{- /* /define[0] */ -}}

{{- define "lib.core.pod.container.securityContext" }} {{- /* define[0] */ -}}
securityContext:
{{- if  not .securityContext }} {{- /* if[1] */}}
# ---------------------------------------------------------------------
# Using the default security context, if it doesn't work for you,
# please update `.Values.base.workload.containers[].securityContext`
# ---------------------------------------------------------------------
  runAsUser: 2000
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
{{- else }}
{{- with .securityContext }} {{- /* with[2] */}}
{{ toYaml . | indent 2 }}
{{- end }} {{- /* /with[2] */}}
{{- end -}} {{- /* /if[1] */ -}}
{{- end -}} {{- /* /define[0] */ -}}

{{/* 
  * Command and Args are accepting a dict as an argument
	* dict should contain the following keys:
	* 	- ctx
	* 	- command/args (optional list) - When empty, entry is not added
*/}}
{{- define "lib.core.pod.container.command" -}} {{- /* define[0] */ -}}
{{- with .command -}} {{- /* with[1] */ -}}
command:
{{ . | toYaml | indent 2 }}
{{- end -}} {{- /* /with[1] */ -}}
{{- end -}} {{- /* /define[0] */ -}}

{{- define "lib.core.pod.container.args" -}} {{- /* define[0] */ -}}
{{- with .args -}} {{- /* with[1] */ -}}
args: 
{{ . | toYaml | indent 2 }}
{{- end -}} {{- /* /with[1] */ -}}
{{- end -}} {{- /* /define[0] */ -}}

{{/* 
  * Probes are accepting a dict as an argument
	* dict should contain the following keys:
	* 	- ctx
	* 	- probe (optional) - When empty, probe is not added
  *
  * Notes: Probes can be tempalted, because some kinds of probes
  * need to be aware of a port to be checking against. And to avoid
  * copypaste all the probes are tempalted
*/}}

{{- define "lib.core.pod.container.readinessProbe" -}} {{- /* define[0] */ -}}
{{- include "lib.error.noCtx" . -}}
{{- include "lib.error.noKey" (dict "ctx" . "key" "probe") -}}
{{- if .probe }} {{- /* if[1] */}}
{{- $probe := tpl (toYaml .probe) .ctx -}}
readinessProbe:
{{ $probe | indent 2}}
{{- end }} {{- /* /if[1] */}}
{{- end -}} {{- /* /define[0] */ -}}

{{- define "lib.core.pod.container.livenessProbe" -}} {{- /* define[0] */ -}}
{{- include "lib.error.noCtx" . -}}
{{- include "lib.error.noKey" (dict "ctx" . "key" "probe") -}}
{{- if .probe }} {{- /* if[1] */}}
{{- $probe := tpl (toYaml .probe) .ctx -}}
livenessProbe:
{{ $probe | indent 2}}
{{- end }} {{- /* /if[1] */}}
{{- end -}} {{- /* /define[0] */ -}}

{{- define "lib.core.pod.container.startupProbe" -}} {{- /* define[0] */ -}}
{{- include "lib.error.noCtx" . -}}
{{- include "lib.error.noKey" (dict "ctx" . "key" "probe") -}}
{{- if .probe }} {{- /* if[1] */}}
{{- $probe := tpl (toYaml .probe) .ctx -}}
startupProbe:
{{ $probe | indent 2}}
{{- end }} {{- /* /if[1] */}}
{{- end -}} {{- /* /define[0] */ -}}

