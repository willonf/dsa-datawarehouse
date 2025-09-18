# Use a imagem oficial do Ubuntu como base
FROM ubuntu:latest

# Atualizar os pacotes do sistema e instalar dependências necessárias
RUN apt-get update && \
    apt-get install -y wget unzip curl openssh-client iputils-ping gnupg lsb-release

# Definir a versão do iac (ajuste conforme necessário)
ENV TERRAFORM_VERSION=1.12.2

# Baixar e instalar iac
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Criar a pasta /lab1 como um ponto de montagem para um volume
RUN mkdir /lab1
VOLUME /lab1

# Adicionar o repositório do Google Cloud SDK e instalar
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    apt-get update && apt-get install -y google-cloud-sdk

# Definir o comando padrão para execução quando o container for iniciado
CMD ["/bin/bash"]
