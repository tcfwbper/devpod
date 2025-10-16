{{- /*
Copyright Tsung-Han Chang. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/*
Return the proper DevPod image name
*/}}
{{- define "devpod.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container image whose tag is with suffix "init-workspace")
*/}}
{{- define "devpod.initWorkspace.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.initWorkspace.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container image whose tag is with suffix "init-workspace-docker-socket")
*/}}
{{- define "devpod.initWorkspace.dockerSocketImage" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.initWorkspace.dockerSocketImage "global" .Values.global) }}
{{- end -}}

{{/*
Return the Docker-In-Docker image name
*/}}
{{- define "devpod.dockerDaemon.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.docker.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "devpod.imagePullSecrets" -}}
{{ include "common.images.renderPullSecrets" (dict "images" (list .Values.image .Values.initWorkspace.image) "context" $) }}
{{- end -}}

{{/*
 Create the name of the service account to use
 */}}
{{- define "devpod.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Get DevPod password secret name.
*/}}
{{- define "devpod.secretPasswordName" -}}
    {{- if .Values.auth.existingPasswordSecret -}}
        {{- printf "%s" (tpl .Values.auth.existingPasswordSecret $) -}}
    {{- else -}}
        {{- printf "%s" (include "common.names.fullname" .) -}}
    {{- end -}}
{{- end -}}

{{/*
Get the password key to be retrieved from DevPod secret.
*/}}
{{- define "devpod.secretPasswordKey" -}}
    {{- if and .Values.auth.existingPasswordSecret .Values.auth.existingSecretPasswordKey -}}
        {{- printf "%s" (tpl .Values.auth.existingSecretPasswordKey $) -}}
    {{- else -}}
        {{- printf "ubuntu-password" -}}
    {{- end -}}
{{- end -}}

{{/*
Return DevPod password
*/}}
{{- define "devpod.password" -}}
    {{- if not (empty .Values.auth.password) -}}
        {{- .Values.auth.password -}}
    {{- else -}}
        {{- include "getValueFromSecret" (dict "Namespace" (include "common.names.namespace" .) "Name" (include "devpod.secretPasswordName" .) "Key" (include "devpod.secretPasswordKey" .))  -}}
    {{- end -}}
{{- end }}

{{/*
Compile all warnings into a single message, and call fail.
*/}}
{{- define "devpod.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "devpod.validateValues.username" .) -}}
{{- $messages := append $messages (include "devpod.validateValues.password" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}

{{/*
Validate values of devpod - username
*/}}
{{- define "devpod.validateValues.username" -}}
{{- if not .Values.auth.username }}
devpod: auth.username
    Missing mandatory key `auth.username`.
    Please fill out your username to deploy devpod.
{{- end -}}
{{- end -}}

{{/*
Validate values of devpod - password
*/}}
{{- define "devpod.validateValues.password" -}}
{{- if not .Values.auth.password }}
devpod: auth.password
    Missing mandatory key `auth.password`.
    Please fill out your password to deploy devpod.
{{- end -}}
{{- end -}}

{{/*
Get the initialization scripts volume name.
*/}}
{{- define "devpod.initScripts" -}}
{{- printf "%s-init-scripts" (include "common.names.fullname" .) -}}
{{- end -}}

{{/*
Returns the available value for certain key in an existing secret (if it exists)
*/}}
{{- define "getValueFromSecret" }}
    {{- $obj := (lookup "v1" "Secret" .Namespace .Name).data -}}
    {{- if $obj }}
        {{- index $obj .Key | trimAll "\"" | b64dec -}}
    {{- end }}
{{- end }}

{{/*
Returns packages that will be installed
*/}}
{{- define "devpod.packages" -}}
{{- if .Values.packages.apt }}
DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y {{- range .Values.packages.apt }} {{ . | quote }}{{ end }} || true
apt-get clean
rm -rf /var/lib/apt/lists/*
unset DEBIAN_FRONTEND
{{- end }}
{{- if .Values.packages.pip }}
pip install --no-cache-dir {{- range .Values.packages.pip }} {{ . | quote }}{{ end }} || true
{{- end }}
{{- end -}}
