{
  cacert,
  check_interfaces,
  deterministic-uname,
  dockerTools,
  dumb-init,
  fakeNss,
  iana-etc,
  icinga-container-entrypoint,
  icinga2,
  icingaGroup,
  icingaUser,
  manubulon-snmp-plugins,
  monitoring-plugins,
  openbsd_snmp3_check,
  stdenv,
}:
dockerTools.buildLayeredImage {
  name = "localhost/icinga-snmp";
  tag = "${stdenv.hostPlatform.system}";
  compressor = "zstd";

  contents = [
    cacert
    check_interfaces
    deterministic-uname
    dumb-init
    fakeNss

    # perlPackages.NetSNMP calls getprotobyname which requires the /etc/protocols file.
    iana-etc

    icinga2
    icinga-container-entrypoint
    manubulon-snmp-plugins
    monitoring-plugins
    openbsd_snmp3_check
  ];

  extraCommands = ''
    set -eou pipefail
    # Create the /run and /var directories that are expected.
    mkdir --parents run var/cache var/lib var/log var/spool
    ln --symbolic --verbose /run var/run
  '';

  fakeRootCommands = ''
    set -eou pipefail

    # Create the /data and /data-init directories.
    # install --group ${icingaGroup} --owner ${icingaUser} --directory data
    install --group ${icingaGroup} --owner ${icingaUser} --directory data
    install --group ${icingaGroup} --owner ${icingaUser} --directory data-init
    install --group ${icingaGroup} --owner ${icingaUser} --directory data-init/etc

    # Copy Icinga's configuration under /data-init/etc and make /etc/icinga2 a symlink to /data/etc/icinga2.
    cp --recursive ${icinga2}/etc/icinga2 data-init/etc/
    chown --recursive ${icingaUser}:${icingaGroup} data-init/etc/icinga2
    find data-init/etc/icinga2 -type d -exec chmod 0755 {} \;
    find data-init/etc/icinga2 -type f -exec chmod 0644 {} \;
    rm --force --recursive etc/icinga2
    ln --symbolic --verbose /data/etc/icinga2 etc/icinga2

    # Create the /var subdirectories Icinga expects.
    install --group ${icingaGroup} --owner ${icingaUser} --directory \
      data-init/var/cache/icinga2 \
      data-init/var/cache/icinga2 \
      data-init/var/lib/icinga2 \
      data-init/var/log/icinga2 \
      data-init/var/run/icinga2 \
      data-init/var/spool/icinga2
    ln --symbolic --verbose /data/var/cache/icinga2 var/cache/icinga2
    ln --symbolic --verbose /data/var/lib/icinga2 var/lib/icinga2
    ln --symbolic --verbose /data/var/log/icinga2 var/log/icinga2
    ln --symbolic --verbose /data/var/run/icinga2 run/icinga2
    ln --symbolic --verbose /data/var/spool/icinga2 var/spool/icinga2
  '';

  config = {
    Cmd = [
      "${icinga2}/bin/icinga2"
      "daemon"
    ];
    Entrypoint = [ "${icinga-container-entrypoint}/bin/entrypoint" ];
    ExposedPorts = {
      "5665" = { };
    };
    User = "icinga2";
  };
}
