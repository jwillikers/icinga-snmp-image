{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nix-update-scripts.url = "github:jwillikers/nix-update-scripts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };
  outputs =
    {
      # deadnix: skip
      self,
      nix-update-scripts,
      nixpkgs,
      flake-utils,
      pre-commit-hooks,
      treefmt-nix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [
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
        ];
        pkgs = import nixpkgs { inherit system overlays; };
        icingaGroup = "5665";
        icingaUser = "5665";
        check_interfaces = pkgs.callPackage ./packages/check_interfaces.nix { };
        icinga-container-entrypoint = pkgs.callPackage ./packages/icinga-container-entrypoint.nix { };
        manubulon-snmp-plugins = pkgs.callPackage ./packages/manubulon-snmp-plugins.nix { };
        openbsd_snmp3_check = pkgs.callPackage ./packages/openbsd_snmp3_check.nix { };
        icinga-snmp-image = pkgs.callPackage ./packages/icinga-snmp-image.nix {
          inherit
            check_interfaces
            icinga-container-entrypoint
            icingaUser
            icingaGroup
            manubulon-snmp-plugins
            openbsd_snmp3_check
            ;
        };
        treefmt = {
          config = {
            programs = {
              actionlint.enable = true;
              jsonfmt.enable = true;
              just.enable = true;
              nixfmt.enable = true;
              statix.enable = true;
              taplo.enable = true;
              typos.enable = true;
              yamlfmt.enable = true;
            };
            projectRootFile = "flake.nix";
            settings.formatter = {
              typos.excludes = [ ".vscode/settings.json" ];
            };
          };
        };
        treefmtEval = treefmt-nix.lib.evalModule pkgs treefmt;
        pre-commit = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            check-added-large-files.enable = true;
            check-builtin-literals.enable = true;
            check-case-conflicts.enable = true;
            check-executables-have-shebangs.enable = true;

            # todo Not integrated with Nix?
            check-format = {
              enable = true;
              entry = "${treefmtEval.config.build.wrapper}/bin/treefmt --fail-on-change";
            };

            check-json.enable = true;
            check-shebang-scripts-are-executable.enable = true;
            check-toml.enable = true;
            check-yaml.enable = true;
            deadnix.enable = true;
            detect-private-keys.enable = true;
            editorconfig-checker.enable = true;
            end-of-file-fixer = {
              enable = true;
              excludes = [ "\\.patch" ];
            };
            fix-byte-order-marker.enable = true;
            # todo Broken for 24.05 branch
            # flake-checker.enable = true;
            forbid-new-submodules.enable = true;
            # todo Enable lychee when asciidoc is supported.
            # See https://github.com/lycheeverse/lychee/issues/291
            # lychee.enable = true;
            mixed-line-endings.enable = true;
            nil.enable = true;
            trim-trailing-whitespace = {
              enable = true;
              excludes = [ "\\.patch" ];
            };
            yamllint.enable = true;
          };
        };
      in
      with pkgs;
      {
        apps = {
          inherit (nix-update-scripts.apps.${system}) update-nix-direnv;
          inherit (nix-update-scripts.apps.${system}) update-nixos-release;
          update-packages =
            let
              script = pkgs.writeShellApplication {
                name = "update-packages";
                text = ''
                  set -eou pipefail
                  ${pkgs.nix-update}/bin/nix-update check_interfaces --build --flake
                  ${pkgs.nix-update}/bin/nix-update icinga-container-entrypoint --build --flake --version master
                  ${pkgs.nix-update}/bin/nix-update manubulon-snmp-plugins --build --flake
                  ${pkgs.nix-update}/bin/nix-update openbsd_snmp3_check --build --flake
                  ${treefmtEval.config.build.wrapper}/bin/treefmt
                '';
              };
            in
            {
              type = "app";
              program = "${script}/bin/update-packages";
            };
        };
        devShells.default = mkShell {
          inherit (pre-commit) shellHook;
          nativeBuildInputs =
            with pkgs;
            [
              asciidoctor
              fish
              dive
              just
              lychee
              nil
              treefmtEval.config.build.wrapper
              # Make formatters available for IDE's.
              (lib.attrValues treefmtEval.config.build.programs)
            ]
            ++ pre-commit.enabledPackages;
        };
        formatter = treefmtEval.config.build.wrapper;
        packages = {
          default = self.packages.${system}.icinga-snmp-image;
          inherit check_interfaces;
          inherit manubulon-snmp-plugins;
          inherit icinga-container-entrypoint;
          inherit icinga-snmp-image;
          inherit openbsd_snmp3_check;
        };
      }
    );
}
