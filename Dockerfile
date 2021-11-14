FROM ubuntu:20.04

RUN apt update && apt-get install software-properties-common -y
RUN add-apt-repository universe && \
  add-apt-repository multiverse && \
  apt update && \
  apt install -y  pdns-server less nano pdns-backend-pipe

RUN apt-get update -q && apt-get install -y git curl gnupg jq build-essential gawk zip

RUN git clone --depth 1 https://github.com/asdf-vm/asdf.git $HOME/.asdf && \
    echo '. $HOME/.asdf/asdf.sh' >> $HOME/.bashrc && \
    echo '. $HOME/.asdf/asdf.sh' >> $HOME/.profile 


ENV PATH="${PATH}:/root/.asdf/shims:/root/.asdf/bin"
SHELL ["/bin/bash", "-c"]
WORKDIR /root

RUN asdf plugin-add ruby
RUN apt install -y libssl-dev zlib1g-dev
COPY .tool-versions .

RUN asdf install 

COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install

RUN rm -rf /etc/powerdns/*
COPY powerdns/pdns.conf /etc/powerdns/

COPY sslthing.rb .

EXPOSE 53

ENTRYPOINT [ "pdns_server" ]

