FROM docker.io/icinga/icinga2:latest

USER root
RUN apt-get update \
     && apt-get --no-install-recommends --yes install \
          libcrypt-des-perl \
          libcrypt-rijndael-perl \
          libdigest-hmac-perl \
          nagios-snmp-plugins \
          netbase \
     && rm --force --recursive /var/lib/apt/lists/* \
     && curl --location --output /usr/share/perl5/Net/SNMP/Security/USM.pm \
          https://raw.githubusercontent.com/Napsty/scripts/master/perl-net-snmp-sha2/USM.pm

USER icinga
