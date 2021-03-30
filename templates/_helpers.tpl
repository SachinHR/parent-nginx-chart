{{/*
Deployment template for busybox, mysql and redis
*/}}
{{- define "parentchart.commontemplate" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "parent-nginx-chart.fullname" . }}
  labels:
    {{- include "parent-nginx-chart.labels" . | nindent 4 }}
spec:
{{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
{{- end }}
  selector:
    matchLabels:
      {{- include "parent-nginx-chart.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "parent-nginx-chart.selectorLabels" . | nindent 8 }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          {{- if eq .Chart.Name "child-redis-chart" }}
          image: "redis"
          {{- else }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          {{- end}}
          {{- if .Values.ports.flag }}
          ports:
            {{- if eq .Chart.Name "child-redis-chart" }}
            - containerPort: 6379
            {{- else }}
            - containerPort: {{.Values.ports.containerPort }}
            {{- end}}
          {{- end}}
          {{- if eq .Chart.Name "child-mysql-chart" }}
          env:
          - name: MYSQL_ROOT_USERNAME
            value: {{ .Values.env.userName }}
          - name: MYSQL_ROOT_PASSWORD
            value: {{ .Values.env.password }}
          {{- end}}
      {{- if eq .Chart.Name "child-busybox-chart" }}
      initContainers:
        - name: "{{ .Chart.Name }}-initcontainer"
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          command: ['sh', '-c', "sleep 2"]
      {{- end}}
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "parent-nginx-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "parent-nginx-chart.fullname" -}}
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
{{- define "parent-nginx-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "parent-nginx-chart.labels" -}}
helm.sh/chart: {{ include "parent-nginx-chart.chart" . }}
{{ include "parent-nginx-chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "parent-nginx-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "parent-nginx-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
