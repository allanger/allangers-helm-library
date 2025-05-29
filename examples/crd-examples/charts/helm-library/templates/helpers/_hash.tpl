{{/*
	* Populate hashes from configmaps and secret to
	* trigger pod restart after config was changed
	* TODO: Remove the extra empty line after annotations
*/}}
{{- define "lib.helpers.hashes" -}} {{- /* define[0] */ -}}
# ---------------------------------------------------------------------
# -- A note from the library:
# -- Pod annotations currently only support hashes of mounted 
# -- config files and env variables 
# ---------------------------------------------------------------------
{{ range $k, $v := .env }} {{/* range[0] */}}
{{
	include "lib.helpers.hash"
	(dict "kind" "env" "name" $k "data" $v.data)
}}
{{ end -}} {{/* /range[0] */ -}}
{{ range $k, $v := .files }} {{/* range[0] */}}
{{
	include "lib.helpers.hash"
	(dict "kind" "file" "name" $k "data" $v.entries)
}}
{{ end -}} {{/* /range[0] */ -}}
{{- end -}} {{- /* /define[0] */ -}}

{{- define "lib.helpers.hash" -}} {{- /* define[0] */ -}}
{{ printf "helm.badhouseplants.net/%s-%s" .kind .name }}: {{ .data | toString | sha256sum }}
{{- end -}} {{- /* /end[0] */ -}}
