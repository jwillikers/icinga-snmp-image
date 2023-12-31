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
     # todo Use an exact commit from the repository.
     # todo Verify against a known SHA here.
     && curl --location --output /usr/share/perl5/Net/SNMP/Security/USM.pm \
          https://raw.githubusercontent.com/Napsty/scripts/master/perl-net-snmp-sha2/USM.pm \
     # todo Verify against a known SHA here.
     # todo Use an exact commit instead of a tag here for reproducibility.
     # This is using the commit at tag v0.55.
     && curl --location --output /usr/lib/nagios/plugins/openbsd_snmp3.py \
          https://raw.githubusercontent.com/alexander-naumov/openbsd_snmp3_check/1b766bdf10bb8175104d874a5bb73fb2e8d46f32/openbsd_snmp3.py \
     && chmod +x /usr/lib/nagios/plugins/openbsd_snmp3.py

USER icinga
