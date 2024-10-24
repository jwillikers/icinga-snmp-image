{
  icingaUser,
  icingaGroup,
  pkgs,
  ...
}:
rec {
  check_interfaces = pkgs.callPackage ./check_interfaces.nix { };
  icinga-container-entrypoint = pkgs.callPackage ./icinga-container-entrypoint/package.nix { };
  manubulon-snmp-plugins = pkgs.callPackage ./manubulon-snmp-plugins.nix { };
  openbsd_snmp3_check = pkgs.callPackage ./openbsd_snmp3_check.nix { };
  icinga-snmp-image = pkgs.callPackage ./icinga-snmp-image.nix {
    inherit
      check_interfaces
      icinga-container-entrypoint
      icingaUser
      icingaGroup
      manubulon-snmp-plugins
      openbsd_snmp3_check
      ;
  };
}
