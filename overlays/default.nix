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
  # Apply Fedora's patches to the Perl Net-SNMP package.
  # https://src.fedoraproject.org/rpms/perl-Net-SNMP/tree/rawhide
  # todo Upstream these patches.
  (_self: super: rec {
    perl = super.perl.override (_oldPerl: {
      overrides = _pkgs: {
        NetSNMP = super.perlPackages.NetSNMP.overrideAttrs (oldAttrs: {
          patches = (oldAttrs.patches or [ ]) ++ [
            (super.fetchpatch2 {
              url = "https://src.fedoraproject.org/rpms/perl-Net-SNMP/raw/6e1d3e8ff2b9bd38dab48301a9d8b5d81ef3b7fe/f/Net-SNMP-v6.0.1-Switch_from_Socket6_to_Socket.patch";
              hash = "sha256-IpVhqI+dXqzauTkLF0Doulg5U33FxHUhqFTp0jeMtMY=";
            })
            (super.fetchpatch2 {
              url = "https://src.fedoraproject.org/rpms/perl-Net-SNMP/raw/6e1d3e8ff2b9bd38dab48301a9d8b5d81ef3b7fe/f/Net-SNMP-v6.0.1-Simple_rewrite_to_Digest-HMAC-helpers.patch";
              hash = "sha256-ZXo9w2YLtPmM1SJLvIiLWefw7SwrTFyTo4eX6DG1yfA=";
            })
            (super.fetchpatch2 {
              url = "https://src.fedoraproject.org/rpms/perl-Net-SNMP/raw/6e1d3e8ff2b9bd38dab48301a9d8b5d81ef3b7fe/f/Net-SNMP-v6.0.1-Split_usm.t_to_two_parts.patch";
              hash = "sha256-A2gsD6DIX1aFSVLbSL/1zKSM1xiM6hWBadJJH7f5E8o=";
            })
            (super.fetchpatch2 {
              url = "https://src.fedoraproject.org/rpms/perl-Net-SNMP/raw/6e1d3e8ff2b9bd38dab48301a9d8b5d81ef3b7fe/f/Net-SNMP-v6.0.1-Add_tests_for_another_usm_scenarios.patch";
              hash = "sha256-U7nNuL35l/zdSzx1jgjp1PmLQn3xzzDw9DGnyeydi2E=";
            })
            (super.fetchpatch2 {
              url = "https://src.fedoraproject.org/rpms/perl-Net-SNMP/raw/6e1d3e8ff2b9bd38dab48301a9d8b5d81ef3b7fe/f/Net-SNMP-v6.0.1-Rewrite_from_Digest-SHA1-to-Digest-SHA.patch";
              hash = "sha256-dznhj1Fcy0iBBl92p825InjkNZixR2MURVQ/b9bVjtc=";
            })
            ./net-snmp-add-sha-algorithms.patch
          ];
          preCheck = super.lib.optionalString super.stdenv.hostPlatform.isLinux ''
            export NIX_REDIRECTS=/etc/protocols=${super.iana-etc}/etc/protocols
            export LD_PRELOAD=${super.libredirect}/lib/libredirect.so
          '';
          propagatedBuildInputs = with super.perlPackages; [
            CryptDES
            CryptRijndael
            DigestHMAC
            DigestSHA
          ];
          doCheck = true;
        });
      };
    });
    perlPackages = perl.pkgs;
  })
]
