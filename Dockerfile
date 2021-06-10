FROM docker.io/ypcs/debian:bullseye

ARG APT_PROXY

RUN /usr/lib/docker-helpers/apt-setup && \
    /usr/lib/docker-helpers/apt-upgrade && \
    apt-get install --assume-yes \
        curl \
        file \
        gnupg2 \
        sudo \
        vim \
        vim-scripts && \
    /usr/lib/docker-helpers/apt-cleanup

#
# Create non-privileged user, but grant sudo access without password
#
RUN adduser --disabled-password --gecos user,,, user && \
    adduser user sudo && \
    echo "user ALL=(ALL) NOPASSWD: ALL" |tee /etc/sudoers.d/user-nopassword

USER user
WORKDIR /home/user

#
# Base image includes some author keys for eg. verifying other external assets
# Let's import such key into user keyring for verifying rest of the
# configuration files we're pulling in.
#
RUN gpg --list-keys && \
    gpg --keyring /usr/share/ypcs/keyring.gpg --export 0xA66F355E | gpg --import && \
    gpg --keyserver keys.openpgp.org --refresh-keys

# FIXME: verify install.sh authenticiy as well...
RUN curl -O https://ypcs.fi/config/install.sh && \
    curl -O https://ypcs.fi/config/install.sh.sha256 && \
    curl -O https://ypcs.fi/config/install.sh.sha256.asc && \
    sha256sum install.* && \
    gpg --verify install.sh.sha256.asc && \
    sh ./install.sh && \
    rm -f install.sh*

CMD ["/usr/bin/bash", "--login"]
