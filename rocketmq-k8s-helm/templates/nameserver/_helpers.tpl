{{/*
Expand the name of the chart.
*/}}
{{- define "rocketmq-nameserver.name" -}}
{{- default .Chart.Name .Values.nameserver.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "rocketmq-nameserver.fullname" -}}
{{- if .Values.nameserver.fullnameOverride }}
{{- .Values.nameserver.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameserver.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "rocketmq-nameserver.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "rocketmq-nameserver.labels" -}}
helm.sh/chart: {{ include "rocketmq-nameserver.chart" . }}
{{ include "rocketmq-nameserver.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "rocketmq-nameserver.selectorLabels" -}}
app.kubernetes.io/name: {{ include "rocketmq-nameserver.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "rocketmq-nameserver.namesrvImage" -}}
{{ .Values.nameserver.image.repository }}:{{ .Values.nameserver.image.tag | default .Chart.AppVersion }}
{{- end }}

{{- define "rocketmq-nameserver.port" -}}
{{- .Values.nameserver.port  }}
{{- end }}
