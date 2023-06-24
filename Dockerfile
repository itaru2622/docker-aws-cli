ARG base=debian:bullseye
FROM ${base}
ARG base


RUN cp -p /etc/skel/.[a-z]* /root/

RUN apt-get update && apt-get install -y apt-transport-https ca-certificates curl  gnupg  lsb-release unzip 

# apt-repo for k8s, helm, docker
RUN curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -; \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main"  | tee -a /etc/apt/sources.list.d/kubernetes.list; \
    curl -fsSL https://helm.baltorepo.com/organization/signing.asc   | apt-key add -; \
    echo "deb https://baltocdn.com/helm/stable/debian/ all main"  | tee -a /etc/apt/sources.list.d/helm-stable-debian.list ; \
    curl -fsSL https://download.docker.com/linux/debian/gpg          | apt-key add -; \
    echo  "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee -a /etc/apt/sources.list.d/docker.list

RUN apt-get update; \
    apt-get install -y bash bash-completion vim make git screen jq  openssh-client dante-client \
                       dnsutils  procps net-tools iputils-ping \
                       kubectl helm  docker-ce  groff

RUN mkdir -p /etc/bash_completion.d; kubectl completion bash > /etc/bash_completion.d/kubectl
RUN echo "escape ^t^t" > /root/.screenrc


######## aws cmds
# AWS cli tool with eksctl(AWS kubectl)
#  basic usage =>    https://hub.docker.com/r/amazon/aws-cli
#    aws-cli   =>    https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html
#    eksctl    =>    https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html
#    aws-iam-auth => https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
#    aws-cdk   =>    https://docs.aws.amazon.com/cdk/latest/guide/getting_started.html

ARG prefix=/opt/aws

# aws-cli
RUN mkdir -p ${prefix}/bin ${prefix}/aws-cli ; \
    mkdir -p /tmp/awscli; \
    ( cd /tmp/awscli; \
      curl -sSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscli.zip; \
      unzip awscli.zip;  \
      ./aws/install -b ${prefix}/bin -i ${prefix}/aws-cli ; \
      echo "complete -C aws_completer aws" > /etc/bash_completion.d/aws; \
    ); \
    rm -rf /tmp/awscli;

# eksctl
RUN curl -sSL "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" \
    | tar xvzf - -C ${prefix}/bin; \
    ${prefix}/bin/eksctl completion bash > /etc/bash_completion.d/eksctl

# aws-iam-authenticator for k8s
ARG dlURL=https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.5.9/aws-iam-authenticator_0.5.9_linux_amd64
RUN curl -sSL ${dlURL} -o ${prefix}/bin/aws-iam-authenticator ; chmod a+x ${prefix}/bin/aws-iam-authenticator

# aws-cdk, for nodejs
#ARG ver_nodejs=lts
#RUN curl -fsSL https://deb.nodesource.com/setup_${ver_nodejs}.x | bash - ;\
#    (apt update; apt install -y nodejs; \
#     cd ${prefix}; npm install aws-cdk-lib )
#ENV NODE_PATH=${prefix}/node_modules
#ENV PATH=${prefix}/node_modules/.bin:${PATH}


# aws CDK for python(3) and boto3
RUN pip3 install aws-cdk-lib \
                 boto3

ENV PATH=${prefix}/bin:${PATH}
RUN mkdir -p /root/.aws /root/.kube /root/.ssh; ln -s /opt/aws/bin /home/bin
VOLUME ${prefix} /root/.aws /root/.kube /home/bin
