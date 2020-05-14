FROM debian:buster-slim

ARG PROJECT_ID
ARG HUGO_VERSION
ARG HUGO_TYPE=_extended

ENV DEBIAN_FRONTEND noninteractive

# install dev tools
# Update all packages
RUN apt-get clean \
    && apt-get -y -q update\
    && apt-get -y -q install\
        curl \
        git\
        screen\
        vim\
        zsh

#            procps \
#            vim \
# Create user for our app
RUN useradd --user-group --create-home --shell /bin/false ${PROJECT_ID}

# set our home
ENV HOME=/home/${PROJECT_ID}

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

# switch to this user
USER ${PROJECT_ID}

# add profile to bash in case dev uses bash
RUN echo "PS1='${PROJECT_ID}:\w$ '" >> ~/.profile \
    && echo ". ~/.profile" > ~/.bashrc

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
    setopt PROMPT_SUBST \n\
    PROMPT='%%~ $ ' \n\
    RPROMPT='' \n" > ~/.zshrc

# setting zsh as default screen
RUN printf "\
    shell \"/usr/bin/zsh\" \n\
    " > ~/.screenrc

RUN git config --global credential.helper store && \
    git config --global http.sslVerify false && \
    git config --global user.email "${VCS_EMAIL}" && \
    git config --global user.name "${VCS_FULLNAME}"

WORKDIR "${HOME}/${APPLICATION_FOLDER}"

# be sure all files are accessible by the user
USER root
RUN chown -R ${PROJECT_ID}:${PROJECT_ID} "${HOME}"
USER ${PROJECT_ID}

# get the first zsh run
RUN zsh -c "source ~/.zshrc"

EXPOSE 1313