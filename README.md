# Development Environment in Pod
This repository was built for developers, who need a reproducible and version controllable dev environment.

The images built by us are "base" images. Only the common tools, which frequently used are installed in the base images. Therefore, we recommend that all developers do maintain their own branch. At least, you should `⚠️build your own dev-env image⚠️` and reset the password of user and root. Otherwise, your entire workspace are severely threatened.

## Maintain your dev-env
Maintain our environment is a critical task for everyone. It requires some extra effort from us but it will be worth it in the long run. 

Please refer to the [Dockerfile](docker/dev-env/Dockerfile) in dev-env. Though we don't need to revise any ENV sections of Dockerfile, we explain what these environment variables are for extension:
| Env | Description |
| ------------- | ------------- |
| UBUNTU_ACCOUNT | This is your user name. Docker will create a sudoer named by this value for you. Please use this user while developing, or our product might fail because of permissions. |
| UBUNTU_PWD  | This is the password of your user and root. You must change this value, or your dev-env would be exposed to potential threats. |
| USER_ID | You can assign your user ID of your Ubuntu user. However, if you change user ID, you might loss your permissions to access your workspace. This is why we don't recommend revising this value when you upgrade your dev-env image. |
| GROUP_ID | You can assign your group ID of your Ubuntu user. For the same reason, we don't recommend revising this value when you upgrade your dev-env image. |

DOCKER_COMPOSE_VERSION, NODE_VERSION, PYTHON_PACKAGE_NAME, KUBECTL_VERSION, K9S_VERSION, and AZ_CLI_VERSION are the versions of the common tools. We use these environment variables to implement a version-controlled environment.

When you need a tool which didn't be installed, you can follow what we did to maintain your own Dockerfile. Declare the version of this tool, and add a section to install your tool.

## Build dev-env
The following script helps us build the dev-env:
```
bash scripts/build-dev-env.sh
```

## Setup storage
Prerequisite: [nfs-subdir-external-provisioner](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner) if you are deploying devpod on-premisely.
```
# on-prem
bash scripts/on-prem-deploy-storage.sh
# cloud
bash scripts/azure-deploy-storage.sh
```

## (Opt.) Setup Docker
Just install docker if you are deploying devpod on-premisely.

Run the following script if you are deploying devpod on cloud.
```
bash scripts/azure-deploy-docker-daemon.sh
```

## Deploy devpod
The following script helps us deploy the devpod:
```
bash scripts/deploy-dev-pod.sh
```

## SSH to devpod on cloud through ingress-nginx
If you are deploying devpod on-premisely, skip this step.

Prerequisite: [ingress-nginx](https://github.com/kubernetes/ingress-nginx)

1. Ensure that the configmap named `tcp-services` exists and that the `<port number>` is forwarded to the correct service.
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: tcp-services
  namespace: ingress-nginx
data:
  <port number>: "<namespace>/<your service>:<port number>::<domain name>"
```
2. Ensure the following item is added to `spec.template.spec.containers.args` of the deployment named `ingress-nginx-controller`:
```
  - --tcp-services-configmap=ingress-nginx/tcp-services
```
3. Edit the service named `ingress-nginx-controller`. Add the following item in `spec.ports` to allow to access the port:
```
    - name: port-<port number>
    port: <port number>
    targetPort: <port number>
```

Now, you can login to devpod by
```
ssh <user>@<domain name> -p <port number>
```

## Login to devpod
You can now login to devpod by the following commands:
```
# on-prem
ssh <username>@<your host> -p <NodePort>

# cloud
ssh <username>@<your domain name> -p <your port>
```
If you are using `v0.1.0-demo`, the default credential is:
```
username: user
password: password
```
