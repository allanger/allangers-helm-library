{{- define "lib.error.noCtx" -}} {{- /* define[0] */ -}}
{{- if not .ctx -}}{{- fail "no context provided" -}}{{- end -}}
{{- if not (kindIs "map" .ctx) -}} {{- /* if[1] */ -}}
{{- fail "unexpected type of ctx" -}}
{{- end -}} {{- /* /if[1] */ -}}
{{- end -}} {{- /* /define[0] */ -}}
