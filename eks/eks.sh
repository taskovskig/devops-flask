#!/bin/bash

export AWS_EKS_CLUSTER_NAME=sferatech
export AWS_DEFAULT_REGION=eu-central-1
export AWS_ACCOUNT_ID=111122223333

# Create EKS cluster
eksctl create cluster --version=1.21 --name=${AWS_EKS_CLUSTER_NAME} --nodes=1 --managed --region=${AWS_DEFAULT_REGION} --node-type t3.medium --asg-access

# Create managed node groups
eksctl create nodegroup --cluster=${AWS_EKS_CLUSTER_NAME} --region=${AWS_DEFAULT_REGION} --managed --spot --name=spot-node-group-2vcpu-2gb --instance-types=t3.small --nodes-min=1 --nodes-max=5 --asg-access
eksctl create nodegroup --cluster=${AWS_EKS_CLUSTER_NAME} --region=${AWS_DEFAULT_REGION} --managed --spot --name=spot-node-group-2vcpu-4gb --instance-types=t3.medium --nodes-min=0 --nodes-max=5 --asg-access

# OIDC
aws eks describe-cluster --name ${AWS_EKS_CLUSTER_NAME} --query "cluster.identity.oidc.issuer" --output text
aws iam list-open-id-connect-providers | grep E15FDA0B84E69673A31758FA3C2E1245
eksctl utils associate-iam-oidc-provider --cluster ${AWS_EKS_CLUSTER_NAME} --approve

# ALB Ingress Controller
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.3.0/docs/install/iam_policy.json
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json
eksctl create iamserviceaccount \
  --cluster=${AWS_EKS_CLUSTER_NAME} \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::${AWS_ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=${AWS_EKS_CLUSTER_NAME} \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set image.repository=602401143452.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/amazon/aws-load-balancer-controller


# Delete cluster
eksctl delete nodegroup --cluster=${AWS_EKS_CLUSTER_NAME} --name=spot-node-group-2vcpu-2gb
eksctl delete nodegroup --cluster=${AWS_EKS_CLUSTER_NAME} --name=spot-node-group-2vcpu-4gb
eksctl delete cluster --name ${AWS_EKS_CLUSTER_NAME}
