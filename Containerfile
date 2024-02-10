FROM docker.io/icinga/icinga2:latest

USER root
RUN apt-get update \
     && apt-get --no-install-recommends --yes install \
          autoconf \
          automake \
          build-essential \
          libcrypt-des-perl \
          libcrypt-rijndael-perl \
          libdigest-hmac-perl \
          libsnmp-dev \
          nagios-snmp-plugins \
          netbase \
          unzip \
     && rm --force --recursive /var/lib/apt/lists/* \
     # todo Verify against a known SHA here.
     && curl --location --output /usr/share/perl5/Net/SNMP/Security/USM.pm \
          https://raw.githubusercontent.com/Napsty/scripts/45951a2aae9c27d52dcec5252b638b52ce8a5d45/perl-net-snmp-sha2/USM.pm \
     # todo Verify against a known SHA here.
     # This is using the commit at tag v0.55.
     && curl --location --output /usr/lib/nagios/plugins/openbsd_snmp3.py \
          https://raw.githubusercontent.com/alexander-naumov/openbsd_snmp3_check/1b766bdf10bb8175104d874a5bb73fb2e8d46f32/openbsd_snmp3.py \
     && chmod +x /usr/lib/nagios/plugins/openbsd_snmp3.py \
     && curl --location --output autoconf.tar.xz https://ftp.gnu.org/gnu/autoconf/autoconf-2.72.tar.xz \
     && tar xf autoconf.tar.xz \
     && cd autoconf* \
     && ./configure \
     && make \
     && make install \
     && cd .. \
     && rm --force --recursive autoconf* \
     && curl --location --output automake.tar.xz https://ftp.gnu.org/gnu/automake/automake-1.16.5.tar.xz \
     && tar xf automake.tar.xz \
     && cd automake* \
     && ./configure \
     && make \
     && make install \
     && cd .. \
     && rm --force --recursive automake* \
     && curl --location --output check_interfaces.tar.gz \
          https://github.com/NETWAYS/check_interfaces/archive/a708e554d07efe1eba76c1c5b8f8a4366a4a8ca6.tar.gz \
     && tar xf check_interfaces.tar.gz \
     && rm check_interfaces.tar.gz \
     && cd check_interfaces* \
     && ./configure --libexecdir=/usr/lib/nagios/plugins \
     && make \
     && make install \
     && cd .. \
     && rm --force --recursive v1.4* \
     && apt-get autoremove --purge --yes \
          autoconf \
          automake \
          build-essential \
          unzip
     #
     # todo Package interfacetable?
     # It appears to install a PHP web page, so it probably needs integrated in icingaweb.
     # && curl --location --output interfacetable_v3t.tar.gz \
     #      https://github.com/Tontonitch/interfacetable_v3t/archive/refs/tags/v1.01.tar.gz \
     # && tar xf interfacetable_v3t.tar.gz \
     # && rm interfacetable_v3t.tar.gz \
     # && interfacetable_v3t-*/configure \
     #      --prefix=/usr \
     #      --with-nagios-group=icinga \
     #      --with-nagios-libexec=/usr/lib/nagios/plugins \
     #      --with-nagios-user=icinga

USER icinga
