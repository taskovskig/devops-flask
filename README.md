# devops-flask: A CI/CD showcase for deploying helm release to AWS EKS cluster with GitHub Actions and Terraform
## develop (dev branch)
- Create ECR repository using terraform
- Build image
- Package helm chart
- Test helm chart
## deploy (main/master branch)
- Deploy helm chart
## Notes about reaching k8s control plane within GitHub workflow
The usual EKS setup is such that Kubernetes control plane is not reachable from the internet. One solution is to use a SSH jump host (bastion server) which is vanilla Linux EC2 instance having an Elastic IP, but not accessible at all (no ingress rule in its security group). Its security group should be updated by the corresponding GitHub job so that GH runner's IP address is added to the inbound set of rules. SSH tunnel should be established in order to reach Kubernetes API. Removal of the inbound rule is mandatory after the workflow finishes successfully.
### Example HCL setup of SSH jump host
```
data "aws_subnet_ids" "bastion_public_subnet_ids" {
  vpc_id = var.vpc_id
  filter {
    name = "cidr-block"
    values = [
      var.public_cidr_block_1
    ]
  }
}

resource "aws_security_group" "bastion_allow_ssh" {
  name        = format("%s_bastion_sg_allow_ssh", local.cluster_name)
  description = format("%s: Allow SSH inbound traffic for bastion host", local.cluster_name)
  vpc_id      = var.vpc_id

  egress = [{
    description      = "Outbound traffic"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    security_groups  = []
    prefix_list_ids  = []
    self             = false
  }]

  tags = {
    Name = format("bastion_%s_sg_allow_ssh", local.cluster_name)
  }

  lifecycle {
    ignore_changes = [
      ingress
    ]
  }
}

resource "aws_instance" "bastion_host" {
  ami           = var.bastion-host-config.ami_id
  instance_type = var.bastion-host-config.instance_type
  key_name      = var.bastion-host-config.key_name
  vpc_security_group_ids = [
    aws_security_group.bastion_allow_ssh.id
  ]
  subnet_id                   = tolist(data.aws_subnet_ids.bastion_public_subnet_ids.ids)[0]
  associate_public_ip_address = true

  tags = {
    Name = format("EKS %s Bastion Host", local.cluster_name)
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "bastion_host_eip" {
  instance = aws_instance.bastion_host.id
  vpc      = true

  tags = {
    Name = format("%s_bastion_host_eip", local.cluster_name)
  }
}

```

### /etc/hosts setup of GutHub runner
```
cp /etc/hosts $HOME/etc_hosts
sed -ie 's/127.0.0.1*.localhost/127.0.0.1 localhost kubernetes.default.svc.cluster.local/g;' ${HOME}/etc_hosts
sudo cp ${HOME}/etc_hosts /etc/hosts
```
### Get SSH key from AWS Secrets Manager
```
# Get SSH private key (github-eks)
aws secretsmanager get-secret-value --secret-id eks/keyName/github-eks | jq -r .SecretString > $HOME/.ssh/id_rsa_github_eks
chmod 600 $HOME/.ssh/id_rsa_github_eks
```
### Get the public IP of the GitHub runner
```
    steps:
    - name: Public IP
      id: ip
      uses: haythem/public-ip@v1.2

    - name: Print Public IP
      run: |
        echo ${{ steps.ip.outputs.ipv4 }}
        echo ${{ steps.ip.outputs.ipv6 }}
```
### Set access to k8s control plane
```
aws ec2 authorize-security-group-ingress --region ${AWS_DEFAULT_REGION} --group-id ${EKS_BASTION_SECURITY_GROUP_ID} --ip-permissions  "[{\"IpProtocol\": \"tcp\", \"FromPort\": 22, \"ToPort\": 22, \"IpRanges\": [{\"CidrIp\": \"${{ steps.ip.outputs.ipv4 }}/32\", \"Description\": \"Temporary ingress for GitHub runner deploying to cluster\"}]}]" || true
```
### Get kubeconfig for EKS cluster
```
aws eks update-kubeconfig --name eks-cluster --kubeconfig $HOME/.kube/k8s-github-eks-cluster.conf
sed -ie "s/${K8S_EKS_CLUSTER_API_ENDPOINT}/kubernetes.default.svc.cluster.local:8443/g;" $HOME/.kube/k8s-github-eks-cluster.conf
```
### Establish SSH tunnel via bastion host
ssh -4 -N -f -L 8443:${K8S_EKS_CLUSTER_API_ENDPOINT}:443 ubuntu@${EKS_STAGING_BASTION_IP} -i $HOME/.ssh/id_rsa_github_eks -o StrictHostKeyChecking=no
