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
    apt install sudo -y && \
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
    apt install mongodb -y && \
\
# Install PM2 node service
    npm install --location=global pm2 && \
\
# Generate private/public keys
    mkdir -p /etc/carta && \
    cd /etc/carta && \
    openssl genrsa -out carta_private.pem 4096 && \
    openssl rsa -in carta_private.pem -outform PEM -pubout -out carta_public.pem

RUN \
    groupadd carta-users && \
    useradd  -m --shell=/bin/bash -p "cartatest999" -G carta-users cartatest


COPY Config/config.json /etc/carta/
COPY Config/carta_sudo /etc/sudoers.d/
COPY Config/idia_banner.svg /etc/carta/
COPY Config/start.sh /usr/local/bin/

# think about the UID of a carta user in the inderlying system. This could cause problems. ****

# need to think about how to auth. Could add a test used to this container for now.
# need to think about how to make this start as a user.
# need to think how to mount data volume into this contrainer.

RUN \
#    service mongodb start && \
    chmod +x /usr/local/bin/start.sh

EXPOSE 8000

CMD ["/usr/local/bin/start.sh"]

