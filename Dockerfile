FROM ghost:1.14

# Install openssh for web-ssh access from kudu
RUN apt-get update && apt-get install \
      --no-install-recommends --no-install-suggests -y \
      openssh-server \
	supervisor \
      git \
      && echo "root:Docker!" | chpasswd

# Creating folder so that image won't fail in non-azure
RUN mkdir -p /home/LogFiles

COPY sshd_config /etc/ssh/
COPY init-container.sh /usr/local/bin
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf	

# EXPOSE 2222
CMD ["init-container.sh"]