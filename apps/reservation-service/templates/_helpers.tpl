{{- define "reservation-service.rabbitmq.fullname" -}}
{{- printf "%s-rabbitmq-broker" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}