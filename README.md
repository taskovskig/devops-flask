# devops-flask (CI/CD showcase)
## develop (dev branch)
- Create ECR repository using terraform
- Build image
- Package helm chart
- Test helm chart
## deploy (main/master branch)
- Deploy helm chart
## Notes about reaching k8s control plane
```
cp /etc/hosts $HOME/etc_hosts
sed -ie 's/127.0.0.1*.localhost/127.0.0.1 localhost kubernetes.default.svc.cluster.local/g;' ${HOME}/etc_hosts
sudo cp ${HOME}/etc_hosts /etc/hosts
# Get SSH private key (github-eks)
aws secretsmanager get-secret-value --secret-id eks/keyName/github-eks | jq -r .SecretString > $HOME/.ssh/id_rsa_github_eks
chmod 600 $HOME/.ssh/id_rsa_github_eks
```
Bla, bla