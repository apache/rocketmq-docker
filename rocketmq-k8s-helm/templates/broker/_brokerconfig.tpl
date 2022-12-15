{{- define "rocketmq-broker.config" -}}
{{- $clusterName := include "rocketmq-broker.clusterName" . }}
{{- $brokerNamePrefix := include "rocketmq-broker.brokerNamePrefix" . }}
{{- $config := .Values.broker.config }}
{{- $replicaCount := .Values.broker.replicaCount | int }}
{{- range $index := until $replicaCount }}
    brokerClusterName={{ $clusterName }}
    brokerName={{ $brokerNamePrefix }}-{{ $index }}
    enableNameServerAddressResolve=true

    # common config
    traceOn=true
    autoCreateTopicEnable=true
    autoCreateSubscriptionGroup=true
    enableIncrementalTopicCreation=true
    generateConfigForScaleOutEnable=false
    enableNotifyAfterPopOrderLockRelease=true
    autoMessageVersionOnTopicLen=true

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