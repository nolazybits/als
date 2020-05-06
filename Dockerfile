FROM alpine:3.7

ARG HUGO_VERSION
ARG HUGO_TYPE=_extended

# install dev tools
RUN apk upgrade && \
    apk add --update --no-cache \
        zsh \
        vim \
		build-base \
		ca-certificates \
		curl \
		git \
		libcurl \
# Needed for Hugo Extended which uses CGO
		libc6-compat \
		libxml2-dev \
		libxslt-dev \
		openssh \
		rsync \
		wget

# download hugo to tmp directory
ADD https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo${HUGO_TYPE}_${HUGO_VERSION}_Linux-64bit.tar.gz /tmp

# untar and move it to the proper place
RUN tar -xf /tmp/hugo${HUGO_TYPE}_${HUGO_VERSION}_Linux-64bit.tar.gz -C /tmp \
    && mkdir -p /usr/local/sbin \
    && mv /tmp/hugo /usr/local/sbin/hugo \
    && rm -rf /tmp/hugo${HUGO_TYPE}_${HUGO_VERSION}_linux_amd64 \
    && rm -rf /tmp/hugo${HUGO_TYPE}_${HUGO_VERSION}_Linux-64bit.tar.gz \
    && rm -rf /tmp/LICENSE.md \
    && rm -rf /tmp/README.md

# DEV STUFF
# add zgen
RUN git clone https://github.com/tarjoilija/zgen.git "${HOME}/.zgen"

# edit zshrc
RUN printf "\
export TERM=\"xterm-256color\" \n\
export LC_ALL=en_US.UTF-8 \n\
export LANG=en_US.UTF-8 \n\
export PATH=/usr/local/sbin:\${PATH} \n\
export PATH=~/.local/bin:\${PATH} \n\
export PATH=~/application/node_modules/.bin:\${PATH} \n\
\n\
fpath=(~/.zsh_completion \"\${fpath[@]}\") \n\
\n\
# Source Profile \n\
[[ -e ~/.profile ]] && emulate sh -c 'source ~/.profile' \n\
\n\
# finally load zgen \n\
source \"\${HOME}/.zgen/zgen.zsh\" \n\
\n\
# if the init scipt doesn't exist \n\
if ! zgen saved; then \n\
    echo \"Creating a zgen save\" \n\
\n\
    # Load the oh-my-zsh's library. \n\
    zgen oh-my-zsh \n\
\n\
    # plugins \n\
    zgen oh-my-zsh plugins/git \n\
    zgen oh-my-zsh plugins/command-not-found \n\
    zgen load zsh-users/zsh-syntax-highlighting \n\
    \n\
    # completions \n\
    zgen load zsh-users/zsh-completions src \n\
    \n\
    # theme \n\
    \n\
    # save all to init script \n\
    zgen save \n\
fi \n\
\n\
PROMPT='$ ' \n\
RPROMPT='' \n" > ~/.zshrc

# set git to store credential in file
RUN git config --global credential.helper store

VOLUME /hugo
VOLUME /output

WORKDIR /hugo
# CMD ["zsh", "/run.sh"]

EXPOSE 1313