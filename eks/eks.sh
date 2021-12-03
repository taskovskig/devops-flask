#!/bin/bash

export AWS_EKS_CLUSTER_NAME=sferatech
export AWS_DEFAULT_REGION=eu-central-1

# Create EKS cluster
eksctl create cluster --version=1.21 --name=${AWS_EKS_CLUSTER_NAME} --nodes=1 --managed --region=${AWS_DEFAULT_REGION} --node-type t3.medium --asg-access

# Create managed node groups
eksctl create nodegroup --cluster=${AWS_EKS_CLUSTER_NAME} --region=${AWS_DEFAULT_REGION} --managed --spot --name=spot-node-group-2vcpu-8gb --instance-types=m5.large,m5d.large,m4.large,m5a.large,m5ad.large,m5n.large,m5dn.large --nodes-min=1 --nodes-max=5 --asg-access

eksctl create nodegroup --cluster=${AWS_EKS_CLUSTER_NAME} --region=${AWS_DEFAULT_REGION} --managed --spot --name=spot-node-group-4vcpu-16gb --instance-types=m5.xlarge,m5d.xlarge,m4.xlarge,m5a.xlarge,m5ad.xlarge,m5n.xlarge,m5dn.xlarge --nodes-min=0 --nodes-max=5 --asg-access
