{{- define "omar-basemap.imagePullSecret" }}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .Values.global.imagePullSecret.registry (printf "%s:%s" .Values.global.imagePullSecret.username .Values.global.imagePullSecret.password | b64enc) | b64enc }}
{{- end }}

{{/* Template for env vars */}}
{{- define "omar-basemap.envVars" -}}
  {{- range $key, $value := .Values.envVars }}
  - name: {{ $key | quote }}
    value: {{ $value | quote }}
  {{- end }}
{{- end -}}


{{/*
Return the proper image name
*/}}
{{- define "omar-basemap.image" -}}
{{- $registryName := .Values.image.registry -}}
{{- $imageName := .Values.image.name -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion | toString -}}
{{- if .Values.global }}
    {{- if .Values.global.dockerRepository }}
        {{- printf "%s/%s:%s" .Values.global.dockerRepository $imageName $tag -}}
    {{- else -}}
        {{- printf "%s/%s:%s" $registryName $imageName $tag -}}
    {{- end -}}
{{- else -}}
    {{- printf "%s/%s:%s" $registryName $imageName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "omar-basemap.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default .Values.appName .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* Templates for the volumeMounts section */}}

{{- define "omar-basemap.volumeMounts.configmaps" -}}
{{- range $configmapName, $configmapDict := .Values.configmaps}}
- name: {{ $configmapName | quote }}
  mountPath: {{ $configmapDict.mountPath | quote }}
  {{- if $configmapDict.subPath }}
  subPath: {{ $configmapDict.subPath | quote }}
  {{- end }}
{{- end -}}
{{- end -}}

{{- define "omar-basemap.volumeMounts.pvcs" -}}
{{- range $volumeName := .Values.volumeNames }}
{{- $volumeDict := index $.Values.global.volumes $volumeName }}
- name: {{ $volumeName }}
  mountPath: {{ $volumeDict.mountPath }}
  {{- if $volumeDict.subPath }}
  subPath: {{ $volumeDict.subPath | quote }}
  {{- end }}
{{- end -}}
{{- end -}}

{{- define "omar-basemap.volumeMounts" -}}
{{- include "omar-basemap.volumeMounts.configmaps" . -}}
{{- include "omar-basemap.volumeMounts.pvcs" . -}}
{{- end -}}





{{/* Templates for the volumes section */}}

{{- define "omar-basemap.volumes.configmaps" -}}
{{- range $configmapName, $configmapDict := .Values.configmaps}}
- name: {{ $configmapName | quote }}
  configMap:
    name: {{ $configmapName | quote }}
{{- end -}}
{{- end -}}

{{- define "omar-basemap.volumes.pvcs" -}}
{{- range $volumeName := .Values.volumeNames }}
{{- $volumeDict := index $.Values.global.volumes $volumeName }}
- name: {{ $volumeName }}
  persistentVolumeClaim:
{{- if (pluck "createPVs" $.Values $.Values.global | first) }}
    claimName: "{{ $.Values.appName }}-{{ $volumeName }}-pvc"
{{- else }}
    claimName: "{{ $volumeName }}"
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "omar-basemap.volumes" -}}
{{- include "omar-basemap.volumes.configmaps" . -}}
{{- include "omar-basemap.volumes.pvcs" . -}}
{{- end -}}