{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nix-update-scripts = {
      url = "github:jwillikers/nix-update-scripts";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks.follows = "pre-commit-hooks";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
      };
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
        overlays = import ./overlays { inherit icingaGroup icingaUser; };
        pkgs = import nixpkgs { inherit system overlays; };
        icingaGroup = "5665";
        icingaUser = "5665";
        packages = import ./packages { inherit icingaGroup icingaUser pkgs; };
        pre-commit = pre-commit-hooks.lib.${system}.run (
          import ./pre-commit-hooks.nix { inherit treefmtEval; }
        );
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
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
              (builtins.attrValues treefmtEval.config.build.programs)
            ]
            ++ pre-commit.enabledPackages;
        };
        formatter = treefmtEval.config.build.wrapper;
        packages = packages // {
          default = self.packages.${system}.icinga-snmp-image;
        };
      }
    );
}
