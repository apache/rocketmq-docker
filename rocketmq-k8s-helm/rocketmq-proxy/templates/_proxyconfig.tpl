{{/*
Using mergeOverwrite to merge configs from Values into regional config,
valuse from .Values.config have the higher priority.
*/}}
{{- define "rocketmq-proxy.conf" -}}
{{- $regionalConf := fromYaml (include "rocketmq-proxy.regional.conf" . ) -}}
  rmq-proxy.json: |
{{- end }}

{{- define "rocketmq-proxy.regional.conf" -}}
enableFlowControl: true
enableFlowLimitAction: true
metricCollectorMode: "proxy"
longPollingReserveTimeInMillis: 1000
maxMessageSize: 4194304
maxUserPropertySize: 16384
userPropertyMaxNum: 128
maxMessageGroupSize: 64
grpcClientProducerBackoffInitialMillis: 5
grpcClientProducerBackoffMultiplier: 5
grpcClientProducerBackoffMaxMillis: 1000
transactionHeartbeatBatchNum: 1
rocketMQClusterName= {{ .Values.proxy.rocketMQClusterName }}
namesrvAddr= {{ .Values.proxy.namesrvAddr }}
{{- end -}}