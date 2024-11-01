{
  icingaGroup,
  icingaUser,
  pkgs,
  pkgsUnstable,
  ...
}:
rec {
  icinga-container-entrypoint = pkgs.callPackage ./icinga-container-entrypoint/package.nix { };
  icinga-snmp-image = pkgs.callPackage ./icinga-snmp-image.nix {
    inherit
      icinga-container-entrypoint
      icingaUser
      icingaGroup
      pkgsUnstable
      ;
  };
}
