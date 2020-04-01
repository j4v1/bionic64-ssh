FROM ubuntu:18.04

# Install the needed packages to configure the user and the SSH server
RUN apt-get update \
	&& apt-get install -y openssl \
	&& apt-get install -y openssh-server

# Create a vagrant the 'vagrant' user and add it to sudo group
RUN useradd -rm -d /home/vagrant -s /bin/bash -g root -G sudo -u 1000 -p "$(openssl passwd -1 vagrant)" vagrant  

# Allow 'vagrant' user to login with SSH keys

# allow vagrant to login
# vagrant public extract from: https://github.com/hashicorp/vagrant/blob/master/keys/vagrant.pub
RUN cd /home/vagrant \
  && mkdir .ssh \
  && echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" > .ssh/authorized_keys \
  && chown -R vagrant:sudo .ssh \
  && chmod 0700 .ssh \
  && chmod 0600 .ssh/authorized_keys

# Configure SSH login 
RUN mkdir /var/run/sshd \
	&& sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"

RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]