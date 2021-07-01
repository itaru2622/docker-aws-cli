FROM debian:buster

RUN apt-get update && apt-get install -y apt-transport-https ca-certificates curl  gnupg  lsb-release unzip 

RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main"  | tee -a /etc/apt/sources.list.d/kubernetes.list

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN echo  "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee -a /etc/apt/sources.list.d/docker.list

RUN apt-get update; \
    apt-get install -y groff bash bash-completion dnsutils kubectl docker-ce jq vim make procps net-tools iputils-ping 

RUN cp -p /etc/skel/.[a-z]* /root/

######## aws cmds
# AWS cli tool with eksctl(AWS kubectl)
#  basic usage =>    https://hub.docker.com/r/amazon/aws-cli
#    aws-cli   =>    https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html
#    eksctl    =>    https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/eksctl.html
#    aws-iam-auth => https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/install-aws-iam-authenticator.html

RUN mkdir -p /tmp/awscli; \
    ( cd /tmp/awscli; \
      curl -sSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscli.zip; \
      unzip awscli.zip;  \
      ./aws/install -b /usr/local/bin -i /usr/local/aws-cli ; \
      mkdir -p /etc/bash_completion.d; \
      echo "complete -C aws_completer aws" > /etc/bash_completion.d/aws_bash_completer; \
    ); rm -rf /tmp/awscli;

RUN curl -sSL "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" \
    | tar xvzf - -C /usr/local/bin

RUN curl -sSL https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/aws-iam-authenticator -o /usr/local/bin/aws-iam-authenticator ; \
    chmod a+x /usr/local/bin/aws-iam-authenticator 
