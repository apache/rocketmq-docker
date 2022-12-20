{{/*
Expand the name of the chart.
*/}}
{{- define "rocketmq-broker.name" -}}
{{- default .Chart.Name .Values.broker.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "rocketmq-broker.fullname" -}}
{{- if .Values.broker.fullnameOverride }}
{{- .Values.broker.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.broker.nameOverride }}
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
{{- define "rocketmq-broker.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "rocketmq-broker.labels" -}}
{{ include "rocketmq-broker.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "rocketmq-broker.selectorLabels" -}}
app.kubernetes.io/name: {{ include "rocketmq-broker.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "rocketmq-broker.clusterName" -}}
{{- if .Values.broker.conf.clusterNameOverride }}
{{- .Values.broker.conf.clusterNameOverride | trunc 63 | trimSuffix "-" }}
{{- else -}}
DefaultCluster
{{- end }}
{{- end }}

{{- define "rocketmq-broker.brokerNamePrefix" -}}
{{- if .Values.broker.conf.brokerNamePrefixOverride }}
{{- .Values.broker.conf.brokerNamePrefixOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- include "rocketmq-broker.fullname" . }}
{{- end }}
{{- end }}

{{- define "rocketmq-broker.brokerImage" -}}
{{ .Values.broker.image.repository }}:{{ .Values.broker.image.tag | default .Chart.AppVersion }}
{{- end }}
