## basic use example.


```bash
export DIR_AWS_PROFILE=${HOME}/.aws
export KUBECONFIG=${HOME}/.kube/config

touch ${KUBECONFIG}
docker run --rm -it -e http_proxy=${http_proxy} -e https_proxy=${http_proxy} \
       -v ${DIR_AWS_PROFILE}:/root/.aws \
       -v ${KUBECONFIG}:/root/.kube/config \
       -v /var/run/docker.sock:/var/run/docker.sock \
       itaru2622/aws-cli:latest /bin/bash

# AWS profile   is needed for aws command, keep and share it with host.
# docker.socket is needed for ECR,         to push docker image from local.
# KUBECONFIG    is needed for EKS,         keep and share it with host.
```
