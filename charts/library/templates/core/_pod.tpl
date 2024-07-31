{{- define "lib.core.pod" -}} {{- /* define[0] */ -}}
{{- fail "pods are not implemented net" -}}
{{- end -}} {{- /* /define[0] */ -}}

{{- define "lib.core.pod.securityContext" -}} {{- /* define[0] */ -}}
securityContext:
{{- if not .ctx.Values.workload.securityContext }} {{- /* if[0] */}}
# ---------------------------------------------------------------------
# Using the default security context, if it doesn't work for you,
# please update `.Values.workload.securityContext`
# ---------------------------------------------------------------------
  runAsUser: 1000
  runAsGroup: 3000
  fsGroup: 2000
  seccompProfile:
    type: RuntimeDefault
{{- else -}}
{{- with .ctx.Values.workload.securityContext -}} {{- /* with[0] */ -}}
{{ toYaml . | indent 2 }}
{{- end -}} {{- /* /with[0] */}}
{{- end -}} {{- /* /if[0] */ -}}
{{- end -}} {{- /* define[0] */ -}}


{{- define "lib.core.pod.volumes" -}} {{- /* define[0] */ -}}
{{- if or ( or .ctx.Values.storage .ctx.Values.extraVolumes) .ctx.Values.files -}} {{- /* if[0]*/ -}}
volumes:
  {{- /* If storage is defined, mount a pvc */ -}}
  {{- if .ctx.Values.storage }} {{- /* if[1] */}}
    {{- range $k, $v := .ctx.Values.storage }} {{- /* range[0] */}}
  - name: {{ $k }}-storage
    persistentVolumeClaim:
      claimName: "{{ printf "%s-%s" (include "chart.fullname" $.ctx) $k }}"
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

{{- define "lib.core.pod.containers" -}} {{- /* define[0] */ -}}
{{- if not .Values.workload.containers -}} {{- /* if[0] */ -}}
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
    (dict "Chart" .Context.Chart "Image" .ContainerData.image) 
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

{{- define "lib.core.pod.container.tag" -}} {{/* define[0] */}}
{{- if or .Tag .AppVersion -}} {{/* if[0] */}}
  {{- if .Tag -}} {{/* if[1] */}}
    {{- .Tag -}} 
  {{- else -}}
    {{- .AppVersion  -}}
  {{- end -}} {{/* /if[1] */}}
{{- else -}}
  {{ fail ".Tag or .AppVersion must be passed to this helper (helper.workload.tag)"}}
{{- end -}} {{/* /if[0] */}}
{{- end -}} {{/* /define[0] */}}

{{- define "lib.core.pod.container.image" -}} {{/* define[0] */}}
{{- if and .Chart .Image -}} {{/* if[0] */}}
image: {{ printf "%s/%s:%s" 
  .Image.registry .Image.repository 
  (include "lib.core.pod.container.tag" 
  (dict "AppVersion" $.Chart.AppVersion "Tag" .Image.tag)) 
}}
imagePullPolicy: {{ .Image.pullPolicy | default "Always" }}
{{- else -}}
  {{ fail ".Chart and .Image must be passed to this helper (helper.workload.image)"}}
{{- end -}} {{/* /if[0] */}}
{{- end -}} {{/* /define[0] */}}

{{- define "lib.core.pod.container.command" -}} {{- /* define[0] */ -}}
{{- with .command -}} {{- /* with[0] */ -}}
command:
{{ . | toYaml | indent 2 }}
{{- end -}} {{- /* /with[0] */ -}}
{{- end -}} {{- /* /define[0] */ -}}

{{- define "lib.core.pod.container.args" -}} {{- /* define[0] */ -}}
{{- with .args }} {{- /* with[0] */ -}}
args: 
{{- . | toYaml | indent 2 }}
{{- end -}} {{- /* /with[0] */ -}}
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
  - containerPort: {{ atoi $containerPort }}
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

{{- define "lib.core.pod.container.envFrom" -}} {{- /* define[0] */ -}}
{{- /* If env should be set from a Configmap/Secret */ -}}
{{- if .Container.envFrom }} {{- /* if[0] */}}
envFrom:
{{- range $k := .Container.envFrom -}} {{- /* range[0] */ -}}
{{/* If envFrom entry is a string, then refer to the env created by the library */}}
{{- if kindIs "string" $k -}} {{- /* if[1] */ -}}
{{- if (index $.Context.Values.env $k) -}} {{- /* if[2] */ -}}
{{- if (index $.Context.Values.env $k).sensitive }} {{- /* if[3] */}}
  - secretRef:
{{- else }}
  - configMapRef:
{{- end }} {{- /* /if[3] */}}
      name: {{- printf " %s-%s" (include "chart.fullname" $.Context) $k -}}
{{- end -}} {{- /* /if[2]*/}}
{{- /* Otherwise try to add references directly (if Secrets/ConfigMaps are not managed by the chart) */ -}}
{{- else -}}
{{- $ref := list -}}
{{- $ref = append $ref $k }}
{{ printf "%s" (toYaml $ref) | indent 2}}
{{- end -}} {{- /* /if[1] */ -}}
{{- end -}} {{- /* /range[0] */ -}}
{{- end -}} {{- /* /if[0] */ -}}
{{- end -}} {{- /* /define[0] */ -}}

{{- /* Probes */ -}}
{{- define "lib.core.pod.container.readinessProbe" -}} {{- /* (define) */ -}}
{{- if .readinessProbe }} {{- /* (1) */}}
readinessProbe:
{{ .readinessProbe | toYaml | indent 2 }}
{{- end }} {{- /* /(0) */}}
{{- end -}} {{- /* /(define) */ -}}

{{- define "lib.core.pod.container.livenessProbe" -}} {{- /* (define) */ -}}
{{- if .livenessProbe }} {{- /* (1) */}}
livenessProbe:
{{ .livenessProbe | toYaml | indent 2 }}
{{- end }} {{- /* /(0) */}}
{{- end -}} {{- /* /(define) */ -}}

{{- define "lib.core.pod.container.startupProbe" -}} {{- /* (define) */ -}}
{{- if .startupProbe }} {{- /* (1) */}}
startupProbe:
{{ .startupProbe | toYaml | indent 2 }}
{{- end }} {{- /* /(0) */}}
{{- end -}} {{- /* /(define) */ -}}
