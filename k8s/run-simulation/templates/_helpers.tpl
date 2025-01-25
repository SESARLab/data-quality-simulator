{{ define "simulation.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{ define "simulation.metadata" -}}
namespace: {{ .Release.Namespace }}
labels:
{{ include "simulation.labels" . | indent 2 }}
{{- end }}