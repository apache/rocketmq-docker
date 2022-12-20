{{/*
Using mergeOverwrite to merge configs from Values into regional config,
valuse from .Values.config have the higher priority.
*/}}

{{- define "rocketmq-proxy.conf" -}}
{{- $commonConf := fromYaml (include "rocketmq-proxy.common.conf" . ) -}}
  rmq-proxy.json: |
{{- mergeOverwrite $commonConf .Values.proxy.config | mustToPrettyJson | nindent 4 }}
{{- end }}
{{- define "rocketmq-proxy.common.conf" -}}
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
rocketMQClusterName: "{{ include "rocketmq-broker.clusterName" . }}"
namesrvAddr: "{{ include "rocketmq-nameserver.fullname" . }}:9876"
{{- end -}}