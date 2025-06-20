<!--- app-name: devpod -->

# devpod

Devpod is a non-native kubernetes application that host your development environment.

## TL;DR

```console
helm install my-release oci://ghcr.io/tcfwbper/helm/devpod
```

## Introduction

Hosting your development environment on kubernetes pod has the following advantages:
1. Kubernetes-Native Development for Production Parity: Developing within a Kubernetes cluster ensures a close alignment with production environments, simplifying access to services like ClusterIP. Devpod leverages Kubernetes to mirror the production setup and minimizes discrepancies between development and production. This approach reduces bugs caused by environment mismatches and streamlines testing of Kubernetes-native applications.
2. Portability and Flexibility: Devpod’s portable development environment can be spun up on any Kubernetes cluster, enabling developers to work seamlessly across different setups.
3. Broad IDE Compatibility: Built on SSH, Devpod integrates with popular IDEs like VS Code, MobaXterm, and Vim. This compatibility ensures developers can use their preferred tools without friction.
4. Isolated Environments: Devpod provides isolated environments that shield the host OS from conflicts or issues caused by other developers’ configurations.
5. Scalability: We can manage the development environments at a large scale. This feature makes devpod really suitable for the projects with large number of co-workers and ephemeral users.
6. Cost Efficiency through Resource Management: Kubernetes’ resource management enables dynamic allocation of compute resources, minimizing waste. 
7. Enhanced Security: Running development in containers isolates processes from the host OS, reducing the risk of malicious code execution. Besides, devpod protect your bare machine from the ephemeral, external users who need priviledged authorities.
8. Improved Productivity with Near-Zero Setup: Devpods allow developers to start working on large-scale monorepos immediately, with repositories pre-cloned and tools pre-installed. This near-zero setup time, combined with faster Git and build times (up to 2.5x faster than laptops for complex builds), significantly boosts productivity.

## Prerequisites

- Kubernetes 1.23+
- Helm 3.8.0+
- PV provisioner support in the underlying infrastructure

## Installing the Chart

To install the chart with the release name `my-release`:

```console
helm install my-release oci://REGISTRY_NAME/REPOSITORY_NAME/devpod
```

> Note: You need to substitute the placeholders `REGISTRY_NAME` and `REPOSITORY_NAME` with a reference to your Helm chart registry and repository. For example, `REGISTRY_NAME=ghcr.io` and `REPOSITORY_NAME=tcfwbper/helm`.

The command deploys devpod on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Configuration and installation details

### Configure the Ubuntu user and update credentials

The DevPod chart, when upgrading, reuses the secret previously rendered by the chart. To update credentials, use the following commands:

- Run `helm upgrade` specifying a new username in `auth.username`.
- Run `helm upgrade` specifying a new password in `auth.password`.

### Install packages while postStart

You will loss the changes of system, including APT packages and system Python packages while pod restart. Because PV only holds the files within `/home/{{ .Values.auth.username }}`. The following configuration triggers the installation of API packages and system Python packages every postStart.

```yaml
packages:
  apt:
  - package1
  - package2
  pip:
  - package1
  - package2
```

### Docker daemon

For the most development scenarios, you may need a docker daemon that helps you containerize your applications. The following configurations will start a docker daemon on your pod. We strongly recommend disabling this feature if you don't need a docker daemon. 

```yaml
docker:
  enabled: true
```

### Additional environment variables

In case you want to add extra environment variables (useful for advanced operations like custom init scripts), you can use the `extraEnvVars` property.

```yaml
extraEnvVars:
- name: LOG_LEVEL
  value: error
```

Alternatively, you can use a ConfigMap or a Secret with the environment variables. To do so, use the `extraEnvVarsCM` or the `extraEnvVarsSecret` values.

### Sidecars

If additional containers are needed in the same pod as docker daemon (such as additional servers that you want to host on the same pod), they can be defined using the `sidecars` parameter.

```yaml
sidecars:
- name: your-image-name
  image: your-image
  imagePullPolicy: Always
  ports:
  - name: portname
    containerPort: 1234
```

If these sidecars export extra ports, extra port definitions can be added using the `service.extraPorts` parameter (where available), as shown in the example below:

```yaml
service:
  extraPorts:
  - name: extraPort
    port: 11311
    targetPort: 11311
```

If additional init containers are needed in the same pod, they can be defined using the `initContainers` parameter. Here is an example:

```yaml
initContainers:
  - name: your-image-name
    image: your-image
    imagePullPolicy: Always
    ports:
      - name: portname
        containerPort: 1234
```

Learn more about [sidecar containers](https://kubernetes.io/docs/concepts/workloads/pods/) and [init containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/).

### Pod affinity

This chart allows you to set your custom affinity using the `affinity` parameter. Find more information about Pod affinity in the [kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity).

As an alternative, use one of the preset configurations for pod affinity, pod anti-affinity, and node affinity available at the [bitnami/common](https://github.com/bitnami/charts/tree/main/bitnami/common#affinities) chart. To do so, set the `podAffinityPreset`, `podAntiAffinityPreset`, or `nodeAffinityPreset` parameters.

### Backup and restore

To back up and restore Helm chart deployments on Kubernetes, you need to back up the persistent volumes from the source deployment and attach them to a new deployment using [Velero](https://velero.io/), a Kubernetes backup/restore tool. Find the instructions for using Velero in [this guide](https://techdocs.broadcom.com/us/en/vmware-tanzu/application-catalog/tanzu-application-catalog/services/tac-doc/apps-tutorials-backup-restore-deployments-velero-index.html).

## Persistence

The [devpod](https://hub.docker.com/repository/docker/tcfwbper/dev-env/general) image stores the devpod data at your workspace `/home/{{ .Values.auth.username }}` path of the container. Persistent Volume Claims are used to keep the data across deployments.

If you encounter errors when working with persistent volumes, refer to our [troubleshooting guide for persistent volumes](https://docs.bitnami.com/kubernetes/faq/troubleshooting/troubleshooting-persistence-volumes/).

## Parameters

### Global Parameters

| Name                                                  | Description                                                                                                                                                                                                                                                                                                                                                         | Value   |
| ----------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `global.imageRegistry`                                | Global Docker image registry                                                                                                                                                                                                                                                                                                                                        | `""`    |
| `global.imagePullSecrets`                             | Global Docker registry secret names as an array                                                                                                                                                                                                                                                                                                                     | `[]`    |
| `global.defaultStorageClass`                          | Global default StorageClass for Persistent Volume(s)                                                                                                                                                                                                                                                                                                                | `""`    |
| `global.storageClass`                                 | DEPRECATED: use global.defaultStorageClass instead                                                                                                                                                                                                                                                                                                                  | `""`    |
| `global.security.allowInsecureImages`                 | Allows skipping image verification                                                                                                                                                                                                                                                                                                                                  | `false` |
| `global.compatibility.openshift.adaptSecurityContext` | Adapt the securityContext sections of the deployment to make them compatible with Openshift restricted-v2 SCC: remove runAsUser, runAsGroup and fsGroup and let the platform use their allowed default IDs. Possible values: auto (apply if the detected running cluster is Openshift), force (perform the adaptation always), disabled (do not perform adaptation) | `auto`  |

### DevPod Image Parameters

| Name                | Description                                                                                                             | Value                     |
| ------------------- | ----------------------------------------------------------------------------------------------------------------------- | ------------------------- |
| `image.registry`    | Development environment image registry                                                                                  | `REGISTRY_NAME`           |
| `image.repository`  | Development environment image repository                                                                                | `REPOSITORY_NAME/dev-env` |
| `image.tag`         | Development environment image tag (rebuild your image and set this value)                                               | `1.0.0`                   |
| `image.digest`      | Development environment image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag | `""`                      |
| `image.pullPolicy`  | Development environment image pull policy                                                                               | `IfNotPresent`            |
| `image.pullSecrets` | Specify docker-registry secret names as an array                                                                        | `[]`                      |
| `image.debug`       | Set to true if you would like to see extra information on logs                                                          | `false`                   |

### Common Parameters

| Name                             | Description                                                                                                                                         | Value             |
| -------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------- |
| `nameOverride`                   | String to partially override devpod.fullname template (will maintain the release name)                                                              | `""`              |
| `fullnameOverride`               | String to fully override devpod.fullname template                                                                                                   | `""`              |
| `namespaceOverride`              | String to fully override common.names.namespace                                                                                                     | `""`              |
| `kubeVersion`                    | Force target Kubernetes version (using Helm capabilities if not set)                                                                                | `""`              |
| `extraDeploy`                    | Array of extra objects to deploy with the release                                                                                                   | `[]`              |
| `commonAnnotations`              | Annotations to add to all deployed objects                                                                                                          | `{}`              |
| `servicenameOverride`            | String to partially override headless service name                                                                                                  | `""`              |
| `commonLabels`                   | Labels to add to all deployed objects                                                                                                               | `{}`              |
| `enableServiceLinks`             | Whether information about services should be injected into pod's environment variable                                                               | `true`            |
| `diagnosticMode.enabled`         | Enable diagnostic mode (all probes will be disabled and the command will be overridden)                                                             | `false`           |
| `diagnosticMode.command`         | Command to override all containers in the deployment                                                                                                | `["sleep"]`       |
| `diagnosticMode.args`            | Args to override all containers in the deployment                                                                                                   | `["infinity"]`    |
| `automountServiceAccountToken`   | Mount Service Account token in pod                                                                                                                  | `false`           |
| `hostAliases`                    | Deployment pod host aliases                                                                                                                         | `[]`              |
| `dnsPolicy`                      | DNS Policy for pod                                                                                                                                  | `""`              |
| `dnsConfig`                      | DNS Configuration pod                                                                                                                               | `{}`              |
| `auth.username`                  | DevPod ubuntu username                                                                                                                              | `""`              |
| `auth.password`                  | DevPod ubuntu password                                                                                                                              | `""`              |
| `auth.existingPasswordSecret`    | Existing secret with DevPod ubuntu credentials                                                                                                      | `""`              |
| `auth.existingSecretPasswordKey` | Password key to be retrieved from existing secret                                                                                                   | `ubuntu-password` |
| `command`                        | Override default container command (useful when using custom images)                                                                                | `[]`              |
| `args`                           | Override default container args (useful when using custom images)                                                                                   | `[]`              |
| `lifecycleHooks`                 | Overwrite livecycle for the DevPod container(s) to automate configuration before or after startup                                                   | `{}`              |
| `terminationGracePeriodSeconds`  | Default duration in seconds k8s waits for container to exit before sending kill signal.                                                             | `10`              |
| `extraEnvVars`                   | Extra environment variables to add to DevPod pods                                                                                                   | `[]`              |
| `extraEnvVarsCM`                 | Name of existing ConfigMap containing extra environment variables                                                                                   | `""`              |
| `extraEnvVarsSecret`             | Name of existing Secret containing extra environment variables (in case of sensitive data)                                                          | `""`              |
| `containerPorts.ssh`             |                                                                                                                                                     | `22`              |
| `initScripts`                    | Dictionary of init scripts. Evaluated as a template.                                                                                                | `{}`              |
| `initScriptsCM`                  | ConfigMap with the init scripts. Evaluated as a template.                                                                                           | `""`              |
| `initScriptsSecret`              | Secret containing `/docker-entrypoint-initdb.d` scripts to be executed at initialization time that contain sensitive data. Evaluated as a template. | `""`              |
| `extraContainerPorts`            | Extra ports to be included in container spec, primarily informational                                                                               | `[]`              |
| `extraVolumeMounts`              | Optionally specify extra list of additional volumeMounts                                                                                            | `[]`              |
| `extraVolumes`                   | Optionally specify extra list of additional volumes .                                                                                               | `[]`              |
| `extraSecrets`                   | Optionally specify extra secrets to be created by the chart.                                                                                        | `{}`              |
| `extraSecretsPrependReleaseName` | Set this flag to true if extraSecrets should be created with <release-name> prepended.                                                              | `true`            |

### Statefulset Parameters

| Name                                                | Description                                                                                                                                                                                                       | Value            |
| --------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------- |
| `replicaCount`                                      | Number of DevPod replicas to deploy                                                                                                                                                                               | `1`              |
| `schedulerName`                                     | Use an alternate scheduler, e.g. "stork".                                                                                                                                                                         | `""`             |
| `podManagementPolicy`                               | Pod management policy                                                                                                                                                                                             | `Parallel`       |
| `podLabels`                                         | DevPod Pod labels. Evaluated as a template                                                                                                                                                                        | `{}`             |
| `podAnnotations`                                    | DevPod Pod annotations. Evaluated as a template                                                                                                                                                                   | `{}`             |
| `updateStrategy.type`                               | Update strategy type for DevPod statefulset                                                                                                                                                                       | `RollingUpdate`  |
| `statefulsetLabels`                                 | DevPod statefulset labels. Evaluated as a template                                                                                                                                                                | `{}`             |
| `statefulsetAnnotations`                            | DevPod statefulset annotations. Evaluated as a template                                                                                                                                                           | `{}`             |
| `priorityClassName`                                 | Name of the priority class to be used by DevPod pods, priority class needs to be created beforehand                                                                                                               | `""`             |
| `podAffinityPreset`                                 | Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                                                                                                               | `""`             |
| `podAntiAffinityPreset`                             | Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                                                                                                          | `soft`           |
| `nodeAffinityPreset.type`                           | Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                                                                                                         | `""`             |
| `nodeAffinityPreset.key`                            | Node label key to match Ignored if `affinity` is set.                                                                                                                                                             | `""`             |
| `nodeAffinityPreset.values`                         | Node label values to match. Ignored if `affinity` is set.                                                                                                                                                         | `[]`             |
| `affinity`                                          | Affinity for pod assignment. Evaluated as a template                                                                                                                                                              | `{}`             |
| `nodeSelector`                                      | Node labels for pod assignment. Evaluated as a template                                                                                                                                                           | `{}`             |
| `tolerations`                                       | Tolerations for pod assignment. Evaluated as a template                                                                                                                                                           | `[]`             |
| `topologySpreadConstraints`                         | Topology Spread Constraints for pod assignment spread across your cluster among failure-domains. Evaluated as a template                                                                                          | `[]`             |
| `podSecurityContext.enabled`                        | Enable DevPod pods' Security Context                                                                                                                                                                              | `true`           |
| `podSecurityContext.fsGroupChangePolicy`            | Set filesystem group change policy                                                                                                                                                                                | `OnRootMismatch` |
| `podSecurityContext.sysctls`                        | Set kernel settings using the sysctl interface                                                                                                                                                                    | `[]`             |
| `podSecurityContext.supplementalGroups`             | Set filesystem extra groups                                                                                                                                                                                       | `[]`             |
| `podSecurityContext.fsGroup`                        | Set DevPod pod's Security Context fsGroup                                                                                                                                                                         | `1001`           |
| `containerSecurityContext.enabled`                  | Enabled DevPod containers' Security Context                                                                                                                                                                       | `true`           |
| `containerSecurityContext.seLinuxOptions`           | Set SELinux options in container                                                                                                                                                                                  | `nil`            |
| `containerSecurityContext.runAsUser`                | Set DevPod containers' Security Context runAsUser                                                                                                                                                                 | `0`              |
| `containerSecurityContext.runAsGroup`               | Set DevPod containers' Security Context runAsGroup                                                                                                                                                                | `0`              |
| `containerSecurityContext.runAsNonRoot`             | Set DevPod container's Security Context runAsNonRoot                                                                                                                                                              | `false`          |
| `containerSecurityContext.allowPrivilegeEscalation` | Set container's privilege escalation                                                                                                                                                                              | `true`           |
| `containerSecurityContext.readOnlyRootFilesystem`   | Set container's Security Context readOnlyRootFilesystem                                                                                                                                                           | `false`          |
| `containerSecurityContext.seccompProfile.type`      | Set container's Security Context seccomp profile                                                                                                                                                                  | `RuntimeDefault` |
| `resourcesPreset`                                   | Set container resources according to one common preset (allowed values: none, nano, micro, small, medium, large, xlarge, 2xlarge). This is ignored if resources is set (resources is recommended for production). | `xlarge`         |
| `resources`                                         | Set container requests and limits for different resources like CPU or memory (essential for production workloads)                                                                                                 | `{}`             |
| `livenessProbe.enabled`                             | Enable livenessProbe                                                                                                                                                                                              | `true`           |
| `livenessProbe.initialDelaySeconds`                 | Initial delay seconds for livenessProbe                                                                                                                                                                           | `10`             |
| `livenessProbe.periodSeconds`                       | Period seconds for livenessProbe                                                                                                                                                                                  | `30`             |
| `livenessProbe.timeoutSeconds`                      | Timeout seconds for livenessProbe                                                                                                                                                                                 | `20`             |
| `livenessProbe.failureThreshold`                    | Failure threshold for livenessProbe                                                                                                                                                                               | `3`              |
| `livenessProbe.successThreshold`                    | Success threshold for livenessProbe                                                                                                                                                                               | `1`              |
| `readinessProbe.enabled`                            | Enable readinessProbe                                                                                                                                                                                             | `true`           |
| `readinessProbe.initialDelaySeconds`                | Initial delay seconds for readinessProbe                                                                                                                                                                          | `10`             |
| `readinessProbe.periodSeconds`                      | Period seconds for readinessProbe                                                                                                                                                                                 | `30`             |
| `readinessProbe.timeoutSeconds`                     | Timeout seconds for readinessProbe                                                                                                                                                                                | `20`             |
| `readinessProbe.failureThreshold`                   | Failure threshold for readinessProbe                                                                                                                                                                              | `3`              |
| `readinessProbe.successThreshold`                   | Success threshold for readinessProbe                                                                                                                                                                              | `1`              |
| `startupProbe.enabled`                              | Enable startupProbe                                                                                                                                                                                               | `false`          |
| `startupProbe.initialDelaySeconds`                  | Initial delay seconds for startupProbe                                                                                                                                                                            | `10`             |
| `startupProbe.periodSeconds`                        | Period seconds for startupProbe                                                                                                                                                                                   | `30`             |
| `startupProbe.timeoutSeconds`                       | Timeout seconds for startupProbe                                                                                                                                                                                  | `20`             |
| `startupProbe.failureThreshold`                     | Failure threshold for startupProbe                                                                                                                                                                                | `3`              |
| `startupProbe.successThreshold`                     | Success threshold for startupProbe                                                                                                                                                                                | `1`              |
| `customLivenessProbe`                               | Override default liveness probe                                                                                                                                                                                   | `{}`             |
| `customReadinessProbe`                              | Override default readiness probe                                                                                                                                                                                  | `{}`             |
| `customStartupProbe`                                | Define a custom startup probe                                                                                                                                                                                     | `{}`             |
| `initContainers`                                    | Add init containers to the DevPod pod                                                                                                                                                                             | `[]`             |
| `sidecars`                                          | Add sidecar containers to the DevPod pod                                                                                                                                                                          | `[]`             |
| `packages.apt`                                      | APT packages to install in DevPod pods.                                                                                                                                                                           | `[]`             |
| `packages.pip`                                      | PIP packages to install in DevPod pods.                                                                                                                                                                           | `[]`             |
| `serviceAccount.create`                             | Enable creation of ServiceAccount for DevPod pods                                                                                                                                                                 | `true`           |
| `serviceAccount.name`                               | Name of the created serviceAccount                                                                                                                                                                                | `""`             |
| `serviceAccount.automountServiceAccountToken`       | Auto-mount the service account token in the pod                                                                                                                                                                   | `false`          |
| `serviceAccount.annotations`                        | Annotations for service account. Evaluated as a template. Only used if `create` is `true`.                                                                                                                        | `{}`             |

### Persistence Parameters

| Name                                               | Description                                                                    | Value                               |
| -------------------------------------------------- | ------------------------------------------------------------------------------ | ----------------------------------- |
| `persistence.enabled`                              | Enable DevPod data persistence using PVC                                       | `true`                              |
| `persistence.storageClass`                         | PVC Storage Class for DevPod data volume                                       | `""`                                |
| `persistence.selector`                             | Selector to match an existing Persistent Volume                                | `{}`                                |
| `persistence.accessModes`                          | PVC Access Modes for DevPod data volume                                        | `["ReadWriteOnce"]`                 |
| `persistence.existingClaim`                        | Provide an existing PersistentVolumeClaims                                     | `""`                                |
| `persistence.mountPath`                            | The path the volume will be mounted at                                         | `/home/{{ .Values.auth.username }}` |
| `persistence.subPath`                              | The subdirectory of the volume to mount to                                     | `workspace`                         |
| `persistence.size`                                 | PVC Storage Request for DevPod data volume                                     | `50Gi`                              |
| `persistence.annotations`                          | Persistence annotations. Evaluated as a template                               | `{}`                                |
| `persistence.labels`                               | Persistence labels. Evaluated as a template                                    | `{}`                                |
| `persistentVolumeClaimRetentionPolicy.enabled`     | Enable Persistent volume retention policy for devpod Statefulset               | `false`                             |
| `persistentVolumeClaimRetentionPolicy.whenScaled`  | Volume retention behavior when the replica count of the StatefulSet is reduced | `Retain`                            |
| `persistentVolumeClaimRetentionPolicy.whenDeleted` | Volume retention behavior that applies when the StatefulSet is deleted         | `Retain`                            |

### Exposure Parameters

| Name                                    | Description                                                          | Value       |
| --------------------------------------- | -------------------------------------------------------------------- | ----------- |
| `service.type`                          | Kubernetes Service type                                              | `ClusterIP` |
| `service.portEnabled`                   | Enable ssh port.                                                     | `true`      |
| `service.ports.ssh`                     | SSH service port                                                     | `22`        |
| `service.portNames.ssh`                 | SSH service port name                                                | `ssh`       |
| `service.nodePorts.ssh`                 | Node port for ssh                                                    | `""`        |
| `service.extraPorts`                    | Extra ports to expose in the service                                 | `[]`        |
| `service.loadBalancerSourceRanges`      | Address(es) that are allowed when service is `LoadBalancer`          | `[]`        |
| `service.allocateLoadBalancerNodePorts` | Whether to allocate node ports when service type is LoadBalancer     | `true`      |
| `service.externalIPs`                   | Set the ExternalIPs                                                  | `[]`        |
| `service.externalTrafficPolicy`         | Enable client source IP preservation                                 | `Cluster`   |
| `service.loadBalancerClass`             | Set the LoadBalancerClass                                            | `""`        |
| `service.loadBalancerIP`                | Set the LoadBalancerIP                                               | `""`        |
| `service.clusterIP`                     | Kubernetes service Cluster IP                                        | `""`        |
| `service.labels`                        | Service labels. Evaluated as a template                              | `{}`        |
| `service.annotations`                   | Service annotations. Evaluated as a template                         | `{}`        |
| `service.sessionAffinity`               | Session Affinity for Kubernetes service, can be "None" or "ClientIP" | `None`      |
| `service.sessionAffinityConfig`         | Additional settings for the sessionAffinity                          | `{}`        |

### Init Workspace Parameters

| Name                                                              | Description                                                                                                                                                                                                       | Value                     |
| ----------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------- |
| `initWorkspace.image.registry`                                    | Init Workspace image registry                                                                                                                                                                                     | `REGISTRY_NAME`           |
| `initWorkspace.image.repository`                                  | Init Workspace image repository                                                                                                                                                                                   | `REPOSITORY_NAME/dev-env` |
| `initWorkspace.image.tag`                                         | Init Workspace image tag (rebuild your image and set this value)                                                                                                                                                  | `1.0.0-init-workspace`    |
| `initWorkspace.image.digest`                                      | Init Workspace image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag                                                                                                    | `""`                      |
| `initWorkspace.image.pullPolicy`                                  | Init Workspace image pull policy                                                                                                                                                                                  | `IfNotPresent`            |
| `initWorkspace.image.pullSecrets`                                 | Specify docker-registry secret names as an array                                                                                                                                                                  | `[]`                      |
| `initWorkspace.containerSecurityContext.seLinuxOptions`           | Set SELinux options in container                                                                                                                                                                                  | `nil`                     |
| `initWorkspace.containerSecurityContext.runAsUser`                | Set Init Workspace containers' Security Context runAsUser                                                                                                                                                         | `0`                       |
| `initWorkspace.containerSecurityContext.runAsGroup`               | Set Init Workspace containers' Security Context runAsGroup                                                                                                                                                        | `0`                       |
| `initWorkspace.containerSecurityContext.runAsNonRoot`             | Set Init Workspace container's Security Context runAsNonRoot                                                                                                                                                      | `false`                   |
| `initWorkspace.containerSecurityContext.allowPrivilegeEscalation` | Set container's privilege escalation                                                                                                                                                                              | `true`                    |
| `initWorkspace.containerSecurityContext.readOnlyRootFilesystem`   | Set container's Security Context readOnlyRootFilesystem                                                                                                                                                           | `false`                   |
| `initWorkspace.containerSecurityContext.seccompProfile.type`      | Set container's Security Context seccomp profile                                                                                                                                                                  | `RuntimeDefault`          |
| `initWorkspace.resourcesPreset`                                   | Set container resources according to one common preset (allowed values: none, nano, micro, small, medium, large, xlarge, 2xlarge). This is ignored if resources is set (resources is recommended for production). | `nano`                    |
| `initWorkspace.resources`                                         | Set container requests and limits for different resources like CPU or memory (essential for production workloads)                                                                                                 | `{}`                      |

### Docker deamon Parameters

| Name                                                       | Description                                                                                                                                                                                                       | Value                    |
| ---------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------ |
| `docker.enabled`                                           | Enable docker service in devpod                                                                                                                                                                                   | `true`                   |
| `docker.image.registry`                                    | Docker image registry                                                                                                                                                                                             | `REGISTRY_NAME`          |
| `docker.image.repository`                                  | Docker image repository                                                                                                                                                                                           | `REPOSITORY_NAME/docker` |
| `docker.image.tag`                                         | Docker image tag. It should be a docker-in-docker image                                                                                                                                                           | `dind`                   |
| `docker.image.digest`                                      | Docker image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag                                                                                                            | `""`                     |
| `docker.image.pullPolicy`                                  | Docker image pull policy                                                                                                                                                                                          | `IfNotPresent`           |
| `docker.image.pullSecrets`                                 | Specify docker-registry secret names as an array                                                                                                                                                                  | `[]`                     |
| `docker.containerSecurityContext.seLinuxOptions`           | Set SELinux options in container                                                                                                                                                                                  | `nil`                    |
| `docker.containerSecurityContext.privileged`               | Run Docker containers in privileged mode                                                                                                                                                                          | `true`                   |
| `docker.containerSecurityContext.runAsUser`                | Set Docker containers' Security Context runAsUser                                                                                                                                                                 | `0`                      |
| `docker.containerSecurityContext.runAsGroup`               | Set Docker containers' Security Context runAsGroup                                                                                                                                                                | `0`                      |
| `docker.containerSecurityContext.runAsNonRoot`             | Set Docker container's Security Context runAsNonRoot                                                                                                                                                              | `false`                  |
| `docker.containerSecurityContext.allowPrivilegeEscalation` | Set container's privilege escalation                                                                                                                                                                              | `true`                   |
| `docker.containerSecurityContext.readOnlyRootFilesystem`   | Set container's Security Context readOnlyRootFilesystem                                                                                                                                                           | `false`                  |
| `docker.containerSecurityContext.seccompProfile.type`      | Set container's Security Context seccomp profile                                                                                                                                                                  | `RuntimeDefault`         |
| `docker.resourcesPreset`                                   | Set container resources according to one common preset (allowed values: none, nano, micro, small, medium, large, xlarge, 2xlarge). This is ignored if resources is set (resources is recommended for production). | `micro`                  |
| `docker.resources`                                         | Set container requests and limits for different resources like CPU or memory (essential for production workloads)                                                                                                 | `{}`                     |
| `docker.persistence.enabled`                               | Enable Docker data persistence using PVC                                                                                                                                                                          | `true`                   |
| `docker.persistence.storageClass`                          | PVC Storage Class for Docker data volume                                                                                                                                                                          | `""`                     |
| `docker.persistence.selector`                              | Selector to match an existing Persistent Volume                                                                                                                                                                   | `{}`                     |
| `docker.persistence.accessModes`                           | PVC Access Modes for Docker data volume                                                                                                                                                                           | `["ReadWriteOnce"]`      |
| `docker.persistence.existingClaim`                         | Provide an existing PersistentVolumeClaims                                                                                                                                                                        | `""`                     |
| `docker.persistence.mountPath`                             | The path the volume will be mounted at                                                                                                                                                                            | `/var/lib/docker`        |
| `docker.persistence.subPath`                               | The subdirectory of the volume to mount to                                                                                                                                                                        | `""`                     |
| `docker.persistence.size`                                  | PVC Storage Request for Docker data volume                                                                                                                                                                        | `50Gi`                   |
| `docker.persistence.annotations`                           | Persistence annotations. Evaluated as a template                                                                                                                                                                  | `{}`                     |
| `docker.persistence.labels`                                | Persistence labels. Evaluated as a template                                                                                                                                                                       | `{}`                     |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
helm install my-release \
  --set auth.username=user \
  --set auth.password=password \
    oci://REGISTRY_NAME/REPOSITORY_NAME/devpod
```

> Note: You need to substitute the placeholders `REGISTRY_NAME` and `REPOSITORY_NAME` with a reference to your Helm chart registry and repository. For example, `REGISTRY_NAME=ghcr.io` and `REPOSITORY_NAME=tcfwbper/helm`.

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
helm install my-release -f values.yaml oci://REGISTRY_NAME/REPOSITORY_NAME/devpod
```

> Note: You need to substitute the placeholders `REGISTRY_NAME` and `REPOSITORY_NAME` with a reference to your Helm chart registry and repository. For example, `REGISTRY_NAME=ghcr.io` and `REPOSITORY_NAME=tcfwbper/helm`.
> **Tip**: You can get the default [values.yaml] through `helm show values <chart-name> [--repo <repo-url>]`

## Troubleshooting

Find more information about how to deal with common errors in [this troubleshooting guide](https://docs.bitnami.com/general/how-to/troubleshoot-helm-chart-issues).

## License

Copyright 2025 Tsung-Han Chang. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
