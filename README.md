# devpod

[![License](https://img.shields.io/badge/License-Apache_2.0-blue)](#)
[![Helm](https://img.shields.io/badge/Helm-0F1689?logo=helm&logoColor=fff)](#)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=fff)](#)
[![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=fff)](#)
[![GitHub](https://img.shields.io/badge/GitHub-%23121011.svg?logo=github&logoColor=white)](https://github.com/tcfwbper?tab=repositories)
[![LinkedIn](https://custom-icon-badges.demolab.com/badge/LinkedIn-0A66C2?logo=linkedin-white&logoColor=fff)](https://www.linkedin.com/in/tsung-han-chang-31748b318/)

Devpod is a non-native kubernetes application that host your development environment.

## Why devpod?
1. Kubernetes-Native Development for Production Parity: Developing within a Kubernetes cluster ensures a close alignment with production environments, simplifying access to services like ClusterIP. Devpod leverages Kubernetes to mirror the production setup and minimizes discrepancies between development and production. This approach reduces bugs caused by environment mismatches and streamlines testing of Kubernetes-native applications.
2. Portability and Flexibility: Devpod’s portable development environment can be spun up on any Kubernetes cluster, enabling developers to work seamlessly across different setups.
3. Broad IDE Compatibility: Built on SSH, Devpod integrates with popular IDEs like VS Code, MobaXterm, and Vim. This compatibility ensures developers can use their preferred tools without friction.
4. Isolated Environments: Devpod provides isolated environments that shield the host OS from conflicts or issues caused by other developers’ configurations.
5. Scalability: We can manage the development environments at a large scale. This feature makes devpod really suitable for the projects with large number of co-workers and ephemeral users.
6. Cost Efficiency through Resource Management: Kubernetes’ resource management enables dynamic allocation of compute resources, minimizing waste. 
7. Enhanced Security: Running development in containers isolates processes from the host OS, reducing the risk of malicious code execution. Besides, devpod protect your bare machine from the ephemeral, external users who need priviledged authorities.
8. Improved Productivity with Near-Zero Setup: Devpods allow developers to start working on large-scale monorepos immediately, with repositories pre-cloned and tools pre-installed. This near-zero setup time, combined with faster Git and build times (up to 2.5x faster than laptops for complex builds), significantly boosts productivity.

## Prerequisites
We assume the following infrastructures are installed.
1. storageclass: If there is no proper storageclass installed, you can run `scripts/deploy-storageclass.sh` to have one.

## QuickStart
Please just run `scripts/deploy-devpod.sh` and fill out the arguments. Then, try accessing the devpod through ssh.

To access your devpod:
```
# ClusterIP
kubectl port-forward --namespace <your_ns> svc/<your_svc> <available_port>:22
ssh -p <available_port> <your_username>@0.0.0.0

# NodePort
ssh -p <your_nodeport> <your_username>@<your_node_ip>

# LoadBalancer
SERVICE_IP=$(kubectl get svc --namespace <your_ns> <your_svc> --template '{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}')
ssh <your_username>@$SERVICE_IP
```

## Extra Packages Installation
To ensure the availablility of system packages, we provide `.Values.packages` interface to install these extra packages. However, these packages will be installed every postStart of devpod, which causes a propagation and may block your network if the sizes of the packages are too large. A more graceful way is rebuilding `dev-env` image.
