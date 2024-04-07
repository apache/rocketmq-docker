{{- /*
SPDX-License-Identifier: APACHE-2.0
*/}}

{{- define "controller.jRaftInitConf" -}}
{{- $replicaCount := .Values.controller.replicas | int }}
{{- $args := list -}}
{{- $name := include "controller.fullname" . }}
{{- $namespace := .Release.Namespace -}}
{{- $result := "" -}}
{{- $port := .Values.controller.service.internalport | int -}}
{{- range untilStep 0 $replicaCount 1 -}}
{{-   $args = printf "%s-%d.%s.%s:%d" $name . $name $namespace $port | append $args -}}
{{- end }}
   {{- $result = printf "%s=%s" "jRaftInitConf" (join "," $args) -}}
   {{- $result -}}
{{- end -}}

{{- define "controller.jRaftControllerRPCAddr" -}}
{{- $replicaCount := .Values.controller.replicas | int }}
{{- $args := list -}}
{{- $name := include "controller.fullname" . }}
{{- $namespace := .Release.Namespace -}}
{{- $result := "" -}}
{{- $port := .Values.controller.service.port | int -}}
{{- range untilStep 0 $replicaCount 1 -}}
{{-   $args = printf "%s-%d.%s.%s:%d" $name . $name $namespace $port | append $args -}}
{{- end }}
   {{- $result = printf "%s=%s" "jRaftControllerRPCAddr" (join "," $args) -}}
   {{- $result -}}
{{- end -}}

{{- define "controller.config" -}}
{{- $name := include "controller.fullname" . }}
{{- $config := .Values.controller.config }}
{{- $replicaCount := .Values.controller.replicas | int }}
{{- $jRaftInitConf := include "controller.jRaftInitConf" . -}}
{{- $jRaftControllerRPCAddr := include "controller.jRaftControllerRPCAddr" . -}}
{{- range $index := until $replicaCount }}
  {{ $name }}-{{ $index }}: |
    controllerType=jRaft
    jRaftGroupId=jRaft-controller-group
    jRaftServerId = {{ $name }}-{{ $index }}.{{ $name }}.{{ $.Release.Namespace }}:{{ $.Values.controller.service.internalport }}  
    {{ $jRaftInitConf }}
    {{ $jRaftControllerRPCAddr }}
    jRaftSnapshotIntervalSecs = 3600
    controllerStorePath=/home/rocketmq/store
{{ $config | indent 4 }}
{{- end }}
{{- end }}
