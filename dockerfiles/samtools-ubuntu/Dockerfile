FROM ubuntu:16.04
MAINTAINER Miguel Brown (brownm28@email.chop.edu)

ENV SAMTOOLS_VERSION 1.8

RUN apt update && apt install -y build-essential curl autoconf libcurl4-openssl-dev libz-dev liblzma-dev libssl-dev libncurses5-dev libbz2-dev \
&& curl -OL https://github.com/samtools/samtools/releases/download/1.8/samtools-1.8.tar.bz2 && tar -xjf samtools-1.8.tar.bz2 && rm samtools-1.8.tar.bz2 \
&& cd /samtools-1.8 && ./configure && make && make install \
&& apt remove -y curl && apt autoclean -y  && apt autoremove -y