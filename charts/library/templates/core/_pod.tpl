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
{{- include "lib.error.noKey" (dict "ctx" . "key" "container") -}}
{{- if not .ctx.Values.workload.containers -}} {{- /* if[0] */ -}}
{{ fail ".Values.workload.containers can't be empty" }}
{{- end -}} {{- /* /if[0] */ -}}
containers:
{{- range $k, $v := .Values.workload.containers }} {{- /* range[0] */}}
{{ 
  include "lib.core.pod.container" 
  (dict "Context" $ "ContainerName" $k "ContainerData" $v) 
  | indent 2
}}
{{- end }} {{- /* /range[0] */}}
{{- end -}} {{- /* define[0] */ -}}

{{- define "lib.core.pod.initContainers" -}} {{- /* define[0] */ -}}
{{- end -}} {{- /* define[0] */ -}}

{{- define "lib.core.pod.container" -}} {{- /* define[0] */ -}}
- name: {{ .ContainerName }}
  {{- 
    include "lib.core.pod.container.securityContext" 
    .ContainerData | nindent 2 
  -}}
  {{- 
    include "lib.core.pod.container.image" 
    (dict "chart" .Context.Chart "image" .ContainerData.image) 
    | indent 2 
  -}}
{{- 
  include "lib.core.pod.container.command" .ContainerData | indent 2 
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
{{- end -}} {{- /* /define[0] */ -}}

{{- define "lib.core.pod.container.securityContext" -}} {{- /* define[0] */ -}}
securityContext:
{{- if  not .securityContext }} {{- /* if[0] */}}
# ---------------------------------------------------------------------
# Using the default security context, if it doesn't work for you,
# please update `.Values.workload.container[].securityContext`
# ---------------------------------------------------------------------
  runAsUser: 2000
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
{{- else }}
{{- with .securityContext }} {{- /* with[0] */}}
{{ toYaml . | indent 2 }}
{{- end }} {{- /* /with[0] */}}
{{- end -}} {{- /* /if[0] */ -}}
{{- end -}} {{- /* /define[0] */ -}}

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

{{- define "lib.core.pod.container.image" -}} {{/* define[0] */}}
{{- if and .chart .image -}} {{/* if[1] */}}
image: {{ printf "%s/%s:%s" 
  .image.registry .image.repository 
  (include "lib.core.pod.container.image.tag"
  (dict "appVersion" .chart.AppVersion "tag" .image.tag))
}}
imagePullPolicy: {{ .image.pullPolicy | default "Always" }}
{{- else -}}
  {{ fail ".chart and .image must be passed to this helper (helper.workload.image)"}}
{{- end -}} {{/* /if[1] */}}
{{- end -}} {{/* /define[0] */}}

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
{{ end }} {{/* /if[1] */}}
{{- end -}} {{- /* /define[0] */ -}}

{{- define "lib.core.pod.container.livenessProbe" -}} {{- /* define[0] */ -}}
{{- include "lib.error.noCtx" . -}}
{{- include "lib.error.noKey" (dict "ctx" . "key" "probe") -}}
{{- if .probe }} {{- /* if[1] */}}
{{- $probe := tpl (toYaml .probe) .ctx -}}
livenessProbe:
{{ $probe | indent 2}}
{{ end }} {{/* /if[1] */}}
{{- end -}} {{- /* /define[0] */ -}}

{{- define "lib.core.pod.container.startupProbe" -}} {{- /* define[0] */ -}}
{{- include "lib.error.noCtx" . -}}
{{- include "lib.error.noKey" (dict "ctx" . "key" "probe") -}}
{{- if .probe }} {{- /* if[1] */}}
{{- $probe := tpl (toYaml .probe) .ctx -}}
startupProbe:
{{ $probe | indent 2}}
{{ end }} {{/* /if[1] */}}
{{- end -}} {{- /* /define[0] */ -}}


{{- define "lib.core.pod.container.ports" -}} {{- /* define[0] */ -}}
{{- if .Container.ports }} {{- /* if[0] */}}
ports:
{{- range $k, $v := .Container.ports }} {{- /* range[0] */}}
{{- if and (kindIs "string" $v) (eq $k "raw") }} {{- /* if[1] */}}
{{- fail "raw port should be an array of ports" -}}
{{- end }}
{{- if ne $k "raw" }}
{{- $containerPort := index (index (index $.Context.Values.service $k).ports $v) "targetPort" -}}
{{- $protocol := index (index (index $.Context.Values.service $k).ports $v) "protocol" }}
  - containerPort: {{ $containerPort }}
    protocol: {{ $protocol }}
{{- else }}
{{ $v | toYaml | indent 2 -}}
{{- end -}} {{- /* /if[1] */ -}}
{{- end -}} {{- /* /range[0] */ -}}
{{- end -}} {{- /* /if[1] */ -}}
{{- end -}} {{- /* /define[0] */ -}}

{{- define "lib.core.pod.container.volumeMounts" -}} {{- /* define[0] */ -}}
{{- if .mounts }} {{- /* if[0] */}}
volumeMounts:
{{- range $mountKind, $mountData := .mounts }} {{- /* range[0] */}}
{{- if eq $mountKind "storage" }} {{- /* if[1] */}}
{{- range $mountName, $mountEntry := $mountData }} {{- /* range[1] */}}
  - name: {{ printf "%s-storage" $mountName }}
    mountPath: {{ $mountEntry.path }} 
{{- end }} {{- /* /range[1] */}}
{{- end }} {{- /* /if[1] */}}
{{- if eq $mountKind "files" }} {{- /* if[1] */}}
{{- range $mountName, $mountEntry := $mountData }} {{- /* range[1] */}}
  - name: {{ printf "%s-file" $mountName }}
    mountPath: {{ $mountEntry.path }} 
{{- if $mountEntry.subPath }} {{- /* if[2] */}}
    subPath: {{ $mountEntry.subPath }}
{{- end }} {{- /* /if[2] */}}
{{- end }} {{- /* /range[1] */}}
{{- end }} {{- /* /if[1] */}}
{{- if eq $mountKind "extraVolumes" }} {{- /* if[1] */}}
{{- range $mountName, $mountEntry := $mountData }} {{- /* range[1] */}}
  - name: {{ printf "%s-extra" $mountName }}
    mountPath: {{ $mountEntry.path }} 
{{- end }} {{- /* /range[1] */}}
{{- end }} {{- /* /if[1] */}}
{{- end }} {{- /* /range[0] */}}
{{- end }} {{- /* /if[0] */}}
{{- end -}} {{- /* /define[0] */ -}}


{{/*
  * EnvFrom can either take values from predefined env values
  * or add a raw envFrom entries to the manifests
  * When using the predefined env, it's possible to remove entries
  * using the '.remove' entry from the env mountpoint
  * 
  * Should accept a dict with the followibg keys
  * ctx
  * envFrom
  * 
*/}}
{{- define "lib.core.pod.container.envFrom" -}} {{- /* define[0] */ -}}
{{- include "lib.error.noCtx" . -}}
{{- include "lib.error.noKey" (dict "ctx" . "key" "envFrom") -}}
{{- /* If env should be set from a Configmap/Secret */ -}}
{{- if .envFrom -}} {{- /* if[1] */ -}}
envFrom:
{{- range $k, $v := .envFrom -}} {{- /* range[2] */ -}}
{{- if not (eq $k "raw") -}} {{- /* if[3] */ -}}
{{- $source := include "lib.helpers.lookup.env" (dict "ctx" $.ctx "key" $k) | fromYaml }}
{{- if $source.sensitive }}
  - secretRef:
{{- else }}
  - configMap:
{{- end }}
      name: {{ include "lib.component.env.name" (dict "ctx" $.ctx "name" $k) }}
{{- end }} {{- /* if[3] */}}
{{- end }} {{- /* /range[2] */}}

{{- end -}} {{- /* /if[1] */ -}}
{{- end -}} {{- /* /define[0] */ -}}
