{{- define "lib.core.service" }}
---
# ---------------------------------------------------------------------
# -- This resource is managed by the allanger's helm library
# ---------------------------------------------------------------------
apiVersion: v1
kind: Service
metadata:
  {{- .metadata | nindent 2 }}
spec:
  type: {{ .spec.type }}
  selector:
{{ include "lib.helpers.selectorLabels" .ctx  | indent 4}}
  ports:
{{- range $k,$v := .spec.ports }} {{- /* range[0] */}}
    - name: {{ $k }}
      port: {{ $v.port }}
      targetPort: {{ $v.targetPort}}
      protocol: {{ $v.protocol}}
      {{- with $v.nodePort }}
      nodePort: {{ . }}
      {{- end }}
{{- end }} {{- /* /range[0] */}}
{{- end }}
