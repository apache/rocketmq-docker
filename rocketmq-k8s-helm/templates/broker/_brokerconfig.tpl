{{- define "rocketmq-broker.config" -}}
{{- $name := include "rocketmq-broker.fullname" . }}
{{- $clusterName := include "rocketmq-broker.clusterName" . }}
{{- $brokerNamePrefix := include "rocketmq-broker.brokerNamePrefix" . }}
{{- $config := .Values.broker.config }}
{{- $replicaCount := .Values.broker.replicaCount | int }}
{{- range $index := until $replicaCount }}
  {{ $name }}-{{ $index }}: |
    brokerClusterName={{ $clusterName }}
    brokerName={{ $brokerNamePrefix }}-{{ $index }}
    enableNameServerAddressResolve=true

    # common configs
    traceOn=true
    autoCreateTopicEnable=false
    autoCreateSubscriptionGroup=true
    enableIncrementalTopicCreation=true
    generateConfigForScaleOutEnable=false
    enableNotifyAfterPopOrderLockRelease=true
    autoMessageVersionOnTopicLen=true

    # pop config
    enablePopBufferMerge=true
    enableConsumePopRetryTopic=true
    enableConsumePullRetryTopic=true
    enableSkipLongWaitAck=true

    # Store config
    flushDiskType=SYNC_FLUSH

    # Enable SQL92
    enablePropertyFilter=true

    # Transaction config
    transactionCheckMaxTimeInMs=14400000
    transactionCheckInterval=60000

    # Delay config
    timerWheelEnable=true
    timerMaxDelaySec=86400

    waitTimeMillsInSendQueue=900
    maxMessageSize=5242880

    # stream
    litePullMessageEnable=true
{{ $config | indent 4 }}
{{- end }}
{{- end }}