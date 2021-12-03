#!/bin/bash

export AWS_EKS_CLUSTER_NAME=sferatech
export AWS_DEFAULT_REGION=eu-central-1

# Create EKS cluster
eksctl create cluster --version=1.21 --name=${AWS_EKS_CLUSTER_NAME} --nodes=1 --managed --region=${AWS_DEFAULT_REGION} --node-type t3.medium --asg-access

# Create managed node groups
eksctl create nodegroup --cluster=${AWS_EKS_CLUSTER_NAME} --region=${AWS_DEFAULT_REGION} --managed --spot --name=spot-node-group-2vcpu-2gb --instance-types=t3.small --nodes-min=1 --nodes-max=5 --asg-access

eksctl create nodegroup --cluster=${AWS_EKS_CLUSTER_NAME} --region=${AWS_DEFAULT_REGION} --managed --spot --name=spot-node-group-2vcpu-4gb --instance-types=t3.medium --nodes-min=0 --nodes-max=5 --asg-access
