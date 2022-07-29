FROM ubuntu:20.04

#USER carta

# Add CARTA PPA \
RUN \
    apt update -y && \
    apt install software-properties-common -y && \
    add-apt-repository ppa:cartavis-team/carta && \
    apt update -y && \
# Install the beta backend package with all dependencies
    apt install carta-backend-beta -y && \
    # create a 'carta' user to run the controller
    adduser --system --home /var/lib/carta --shell=/bin/bash --group carta && \
# add 'carta' user to the shadow group (only required for PAM UNIX authentication)
    apt install curl -y && \
    usermod -a -G shadow carta && \
 \
# log directory owned by carta
    mkdir -p /var/log/carta && \
    chown carta: /var/log/carta && \
\
# config directory owned by carta
    mkdir -p /etc/carta && \
    chown carta: /etc/carta && \
\
    # Install the latest NodeJS LTS repo
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
\
# Install NodeJS, NPM and tools required to compile native addons
    apt install -y nodejs build-essential && \
\
# Install carta-controller (includes frontend config)
    npm install --location=global --unsafe-perm carta-controller@beta && \
\
# Install PM2 node service
    npm install --location=global pm2

# Switch to carta user
RUN \
    su - carta && \
\
# Generate private/public keys
    mkdir -p /etc/carta && \
    cd /etc/carta && \
    openssl genrsa -out carta_private.pem 4096 && \
    openssl rsa -in carta_private.pem -outform PEM -pubout -out carta_public.pem

# need to install config scripts.
RUN \
    apt install -y git && \
     git clone https://github.com/robsimmonds/Container01.git && \
     cd Container01/Config && \
     cp config.json /etc/carta && \
     cp carta_sudo /etc/sudoers.d && \
     cp idia_banner.svg /etc/carta;

RUN \
    groupadd carta-users && \
    useradd  --shell=/bin/bash -D -p "cartatest999" cartatest -G carta-users

# think about the UID of a carta user in the inderlying system. This could cause problems. ****

# need to think about how to auth. Could add a test used to this container for now.
# need to think about how to make this start as a user.
# need to think how to mount data volume into this contrainer.

RUN \
    apt install mongodb -y

EXPOSE 8000

CMD ["sh","-c","service mongodb start; sudo su carta; pm2 start --no-daemon carta-controller"]
