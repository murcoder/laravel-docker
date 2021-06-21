FROM nginx:latest

RUN apt-get update && apt-get -y -f install vim dos2unix

# Clean Up Aptitude
RUN apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin && rm -f /etc/nginx/conf.d/default.conf && rm -f /10-listen-on-ipv6-by-default.sh

# Add useful alias
RUN echo 'alias ll="ls -alF"' >> ~/.bashrc