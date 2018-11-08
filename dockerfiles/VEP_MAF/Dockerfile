FROM ubuntu:16.04
MAINTAINER Miguel Brown (brownm28@email.chop.edu)

ENV VEP_VERSION r93

RUN apt update -y && apt upgrade -y && apt install git cpanminus build-essential mysql-client curl libssl-dev wget openssl libmysqlclient-dev unzip wget libncurses5-dev libz-dev libbz2-dev liblzma-dev libcurl4-openssl-dev -y \
&& cpanm -n install DBI DBD::mysql Set::IntervalTree JSON PerlIO::gzip Bio::Root::Version \
&& git clone https://github.com/Ensembl/ensembl-vep.git && cd ensembl-vep && git checkout release/93 \
&& perl INSTALL.pl --NO_TEST --NO_UPDATE --AUTO a \
&& ln -s /ensembl-vep/htslib/bgzip /usr/local/bin && ln -s /ensembl-vep/htslib/tabix /usr/local/bin \
&& cd / && git clone https://github.com/mskcc/vcf2maf \
&& curl -OL https://github.com/samtools/samtools/releases/download/1.8/samtools-1.8.tar.bz2 && tar -xjf samtools-1.8.tar.bz2 && rm samtools-1.8.tar.bz2 \
&& cd samtools-1.8 && make && make install && cd / \
&& apt remove curl wget git -y && apt autoclean -y &&  apt autoremove -y