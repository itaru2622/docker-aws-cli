FROM debian:buster

RUN cp -p /etc/skel/.[a-z]* /root/

RUN apt-get update && apt-get install -y apt-transport-https ca-certificates curl  gnupg  lsb-release unzip 

RUN curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main"  | tee -a /etc/apt/sources.list.d/kubernetes.list

RUN curl -fsSL https://helm.baltorepo.com/organization/signing.asc | apt-key add -; \
    echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee -a /etc/apt/sources.list.d/helm-stable-debian.list

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN echo  "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee -a /etc/apt/sources.list.d/docker.list

#nodejs 14.x for AWS CDK
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash -

RUN apt-get update; \
    apt-get install -y groff bash bash-completion dnsutils   kubectl helm  docker-ce jq vim make procps net-tools iputils-ping nodejs \
                       openssh-client dante-client git screen

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

RUN mkdir -p ${prefix}/bin ${prefix}/aws-cli; mkdir -p /tmp/awscli; \
    ( cd /tmp/awscli; \
      curl -sSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscli.zip; \
      unzip awscli.zip;  \
      ./aws/install -b ${prefix}/bin -i ${prefix}/aws-cli ; \
      mkdir -p /etc/bash_completion.d; \
      echo "complete -C aws_completer aws" > /etc/bash_completion.d/aws; \
    ); rm -rf /tmp/awscli;

RUN curl -sSL "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" \
    | tar xvzf - -C ${prefix}/bin; \
    ${prefix}/bin/eksctl completion bash > /etc/bash_completion.d/eksctl

ARG dlURL=https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/aws-iam-authenticator
RUN curl -sSL ${dlURL} -o ${prefix}/bin/aws-iam-authenticator ; \
    chmod a+x ${prefix}/bin/aws-iam-authenticator

RUN cd ${prefix}; npm install aws-cdk;

# https://aws.amazon.com/blogs/containers/introducing-oidc-identity-provider-authentication-amazon-eks/
RUN ( mkdir -p ${prefix}/cognitouserpool;\
      cd ${prefix}/cognitouserpool ;\
      ${prefix}/node_modules/.bin/cdk init -l typescript ; npm install @aws-cdk/aws-cognito; \
    )

ENV NODE_PATH=${prefix}/node_modules
ENV PATH=${prefix}/bin:${prefix}/node_modules/.bin:${PATH}
RUN mkdir -p /root/.aws /root/.kube; ln -s /opt/aws/bin /home/bin
VOLUME ${prefix} /root/.aws /root/.kube /home/bin
