FROM asolopovas/php-fpm:1.7
ARG USER=www-data
ARG APP_WORKDIR=/var/www/project
RUN mkdir ${APP_WORKDIR}; chown $USER:$USER ${APP_WORKDIR}

# Cron Laravel Task Scheduling
RUN echo "* * * * * cd ${APP_URL} && php artisan schedule:run >> /dev/null 2>&1" >> /etc/crontabs/root

ENV HOME /home/$USER

RUN apk add --no-cache sudo libstdc++ zsh-vcs msmtp jpegoptim optipng pngquant gifsicle libwebp-tools;
RUN ln -sf /usr/bin/msmtp /usr/sbin/sendmail;

RUN echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER; \
    chmod 0440 /etc/sudoers.d/$USER; \
    echo "Set disable_coredump false" > /etc/sudo.conf;

RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/alpine/amd64/$version \
    && mkdir -p /tmp/blackfire \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp/blackfire \
    && mv /tmp/blackfire/blackfire-*.so $(php -r "echo ini_get ('extension_dir');")/blackfire.so \
    && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > $PHP_INI_DIR/conf.d/blackfire.ini \
    && rm -rf /tmp/blackfire /tmp/blackfire-probe.tar.gz

USER $USER

# Node
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | zsh; \
    echo 'export NVM_NODEJS_ORG_MIRROR=https://unofficial-builds.nodejs.org/download/release;' >> $HOME/.profile; \
    echo 'nvm_get_arch() { nvm_echo "x64-musl"; }' >> $HOME/.profile; \
    echo 'source $HOME/.profile;' >> $HOME/.zshrc; \
    echo 'source $HOME/.nvm/nvm.sh' >> $HOME/.zshrc; \
    NVM_DIR="$HOME/.nvm"; source $HOME/.nvm/nvm.sh; source $HOME/.profile; \
    nvm install 14.4.0; \
    npm install -g yarn; \
    npm install -g svgo

# OhMyZsh
RUN git clone "https://github.com/ohmyzsh/ohmyzsh.git" /home/${USER}/.config/ohmyzsh; \
    mkdir -p /home/$USER/.cache; touch /home/$USER/.cache/.zsh_history

# NeoVim
RUN curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim; \
    bash -c "nvim +silent +PlugInstall +qall"

WORKDIR ${APP_WORKDIR}
COPY entry.sh /usr/local/bin/
ENTRYPOINT ["entry.sh"]

# Please note that the Blackfire Probe is dependent on the session module.
# If it isn't present in your install, you will need to enable it yourself.

# Xdebug
USER root
COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
ARG XDEBUG=false
RUN if [ ${XDEBUG} = true ]; then \
    docker-php-ext-enable xdebug \
    ;fi
USER ${USER}

#RUN sudo -u $USER mkdir $HOME/.cache; mkdir $HOME/.config; touch $HOME/.cache/.zsh_history
COPY --chown=$USER:www-data .zshrc $HOME
COPY --chown=$USER:www-data config $HOME/.config/
COPY --chown=$USER:www-data package.json livereload.js /var/www/
COPY config/msmtprc /etc/msmtprc
