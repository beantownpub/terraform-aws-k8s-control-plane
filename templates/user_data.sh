#!/bin/bash

# Log output available on instance in /var/log/cloud-init-output.log
sudo su -
swapoff -a
yum update -y
yum install -y bind-utils git iproute-tc jq nmap

IPV4=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
echo "$${IPV4}    ${kubernetes_api_hostname}" >> /etc/hosts

cat <<EOF | tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

printf "\nInstalling Docker\n"

sysctl --system
amazon-linux-extras install -y docker

mkdir -p /etc/docker
cat <<EOF | tee /etc/docker/daemon.json
{
    "exec-opts": ["native.cgroupdriver=systemd"],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "50m"
    },
    "storage-driver": "overlay2"
}
EOF

service docker start
usermod -a -G docker ec2-user
systemctl enable --now docker
systemctl daemon-reload
systemctl restart docker

setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

printf "\nInstalling K8s Components\n"

yum install -y \
    kubelet \
    kubeadm \
    kubectl \
    --disableexcludes=kubernetes

systemctl enable --now kubelet

printf "\nInitializing K8s Cluster\n"

systemctl enable kubelet.service
swapoff -a

mkdir -p /home/ec2-user/manifests

cat <<EOF | tee /home/ec2-user/manifests/cluster-config.yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
bootstrapTokens:
- token: ${kubernetes_join_token}
  ttl: "0"
localAPIEndpoint:
  bindPort: 6443
nodeRegistration:
  criSocket: "unix:/run/containerd/containerd.sock"
  imagePullPolicy: IfNotPresent
  taints:
  - effect: NoSchedule
    key: node-role.kubernetes.io/master
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
apiServer:
  timeoutForControlPlane: 4m0s
  certSANs:
  - "${kubernetes_api_hostname}"
  extraArgs:
    cloud-provider: external
certificatesDir: /etc/kubernetes/pki
clusterName: ${cluster_name}
controlPlaneEndpoint: "${kubernetes_api_hostname}:6443"
controllerManager: {}
dns: {}
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: k8s.gcr.io
kubernetesVersion: ${kubernetes_version}
networking:
  dnsDomain: cluster.local
  serviceSubnet: ${cluster_cidr}
scheduler: {}
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
providerID: ${cluster_name}
EOF

kubeadm init \
    --config /home/ec2-user/manifests/cluster-config.yaml

mkdir -p "$${HOME}/.kube"
mkdir /home/ec2-user/.kube
cp -i /etc/kubernetes/admin.conf "$${HOME}/.kube"/config
cp -i /etc/kubernetes/admin.conf /home/ec2-user/.kube/config
chown 1000:1000 /home/ec2-user/.kube/config

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

kubectl create ns database

kubectl create ns "${env}" && \
    kubectl label namespace "${env}" istio-injection=enabled

kubectl create ns istio-ingress && \
		kubectl label namespace istio-ingress istio-injection=enabled

printf "\nAdding Helm Repos\n"

helm repo add cilium https://helm.cilium.io/ && \
    helm repo add istio https://istio-release.storage.googleapis.com/charts && \
	helm repo add jetstack https://charts.jetstack.io &&
    helm repo add beantown https://beantownpub.github.io/helm/ && \
    helm repo add aws-ccm https://kubernetes.github.io/cloud-provider-aws && \
    helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver && \
    helm repo update

printf "\nInstalling Cilium CNI\n"

helm upgrade cilium cilium/cilium --install \
    --version ${cilium_version} \
    --namespace kube-system --reuse-values \
    --set hubble.relay.enabled=true \
    --set hubble.ui.enabled=true \
    --set ipam.operator.clusterPoolIPv4PodCIDR="10.7.0.0/16"

sleep 15

helm upgrade istio-base istio/base --install \
    --namespace istio-system \
    --version ${istio_version} \
    --create-namespace

sleep 10

helm upgrade istiod istio/istiod --install \
	--version ${istio_version} \
    --namespace istio-system

helm upgrade istio-ingress istio/gateway --install \
    --version ${istio_version} \
    --namespace istio-ingress \
    --set service.type=None

printf "\nInstalling Cloud Controller Manager\n"

helm upgrade aws-ccm aws-ccm/aws-cloud-controller-manager \
    --install \
    --set args="{\
        --enable-leader-migration=true,\
        --cloud-provider=aws,\
        --v=2,\
        --cluster-cidr=${cluster_cidr},\
        --cluster-name=${cluster_name},\
        --external-cloud-volume-plugin=aws,\
        --configure-cloud-routes=false\
    }"

printf "\nInstalling EBS CSI Driver\n"

helm upgrade --install aws-ebs-csi-driver \
    --namespace kube-system \
    aws-ebs-csi-driver/aws-ebs-csi-driver


kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: aws
provisioner: ebs.csi.aws.com
parameters:
  type: standard
reclaimPolicy: Retain
allowVolumeExpansion: true
mountOptions:
  - debug
volumeBindingMode: WaitForFirstConsumer
EOF

kubectl create -n kube-system sa ${automated_user}
kubectl create -n kube-system token ${automated_user}

kubectl apply -n kube-system -f - <<EOF
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: ${automated_user}
  annotations:
    kubernetes.io/service-account.name: "${automated_user}"
EOF

kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ${automated_user}-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: ${automated_user}
  namespace: kube-system
EOF

# TOKEN_NAME=$(kubectl -n kube-system get sa ${automated_user} -o json | jq '.secrets[0].name' | tr -d '"')
TOKEN=$(kubectl -n kube-system get secret ${automated_user} -o jsonpath='{.data.token}'| base64 --decode)

echo "$${TOKEN}" > /home/ec2-user/${automated_user}_token.txt

helm upgrade --install default-ingress beantown/default-ingress \
    --namespace istio-ingress \
    --set global.env=${env} \
    --set domain=${domain_name} \
    --debug
