{ icingaGroup, icingaUser, ... }:
[
  (_final: prev: {
    fakeNss = prev.fakeNss.override (_old: {
      extraPasswdLines = [
        "icinga2:x:${icingaUser}:${icingaGroup}:icinga2:/var/lib/icinga2:/sbin/nologin"
      ];
      extraGroupLines = [ "icinga2:x:${icingaGroup}:" ];
    });
  })
]
