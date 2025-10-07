{{/*
Expand the name of the chart.
*/}}
{{- define "durantic.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "durantic.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
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
{{- define "durantic.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "durantic.labels" -}}
helm.sh/chart: {{ include "durantic.chart" . }}
{{ include "durantic.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "durantic.selectorLabels" -}}
app.kubernetes.io/name: {{ include "durantic.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "durantic.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "durantic.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate Django secret key if not provided
*/}}
{{- define "durantic.djangoSecretKey" -}}
{{- if .Values.django.secretKey }}
{{- .Values.django.secretKey }}
{{- else }}
{{- randAlphaNum 50 }}
{{- end }}
{{- end }}

{{/*
PostgreSQL host
*/}}
{{- define "durantic.databaseHost" -}}
{{- if .Values.django.database.host }}
{{- .Values.django.database.host }}
{{- else }}
{{- printf "%s-postgresql" .Release.Name }}
{{- end }}
{{- end }}

{{/*
PostgreSQL password - references the subchart secret
*/}}
{{- define "durantic.databasePassword" -}}
{{- if .Values.django.database.existingSecret }}
{{- "PLACEHOLDER_FROM_EXISTING_SECRET" }}
{{- else if .Values.django.database.password }}
{{- .Values.django.database.password }}
{{- else if .Values.postgresql.enabled }}
{{- "POSTGRES_PASSWORD_PLACEHOLDER" }}
{{- else }}
{{- required "django.database.password is required when postgresql.enabled is false and django.database.existingSecret is not set" .Values.django.database.password }}
{{- end }}
{{- end }}

{{/*
Redis host
*/}}
{{- define "durantic.redisHost" -}}
{{- if .Values.django.redis.host }}
{{- .Values.django.redis.host }}
{{- else }}
{{- printf "%s-redis-master" .Release.Name }}
{{- end }}
{{- end }}

{{/*
Redis password - references the subchart secret
*/}}
{{- define "durantic.redisPassword" -}}
{{- if .Values.django.redis.existingSecret }}
{{- "PLACEHOLDER_FROM_EXISTING_SECRET" }}
{{- else if hasKey .Values.django.redis "password" }}
{{- .Values.django.redis.password }}
{{- else if .Values.redis.enabled }}
{{- "REDIS_PASSWORD_PLACEHOLDER" }}
{{- else }}
{{- required "django.redis.password is required when redis.enabled is false and django.redis.existingSecret is not set" .Values.django.redis.password }}
{{- end }}
{{- end }}

{{/*
Control plane node ID
*/}}
{{- define "durantic.controlPlaneNodeId" -}}
{{- if .Values.controlPlane.nodeId }}
{{- .Values.controlPlane.nodeId }}
{{- else }}
{{- printf "%s-%s" (include "durantic.fullname" .) (randAlphaNum 8 | lower) }}
{{- end }}
{{- end }}

{{/*
MinIO endpoint URL
*/}}
{{- define "durantic.minioEndpoint" -}}
{{- if .Values.django.s3.endpointUrl }}
{{- .Values.django.s3.endpointUrl }}
{{- else if .Values.minio.enabled }}
{{- $port := .Values.minio.service.ports.api | toString }}
{{- printf "http://%s-minio:%s" .Release.Name $port }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}


{{/*
Generate JWE Key
*/}}
{{- define "durantic.jweKey" -}}
{{- if .Values.django.jweKey }}
{{- .Values.django.jweKey }}
{{- else }}
{{- randAlphaNum 32 }}
{{- end }}
{{- end }}

{{/*
Generate self-signed CA certificate
*/}}
{{- define "durantic.generateCA" -}}
{{- $ca := genCA .Values.certificates.ca.commonName .Values.certificates.ca.validity -}}
{{- $ca | toJson -}}
{{- end }}

{{/*
Get or generate CA certificate
*/}}
{{- define "durantic.caCert" -}}
{{- if .Values.certificates.ca.cert }}
{{- .Values.certificates.ca.cert }}
{{- else }}
{{- $ca := genCA .Values.certificates.ca.commonName (.Values.certificates.ca.validity | int) -}}
{{- $ca.Cert }}
{{- end }}
{{- end }}

{{/*
Get or generate CA key
*/}}
{{- define "durantic.caKey" -}}
{{- if .Values.certificates.ca.key }}
{{- .Values.certificates.ca.key }}
{{- else }}
{{- $ca := genCA .Values.certificates.ca.commonName (.Values.certificates.ca.validity | int) -}}
{{- $ca.Key }}
{{- end }}
{{- end }}