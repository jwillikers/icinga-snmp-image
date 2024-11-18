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
    # todo Remove dependency on unstable when the required nagiosPlugins are available in the release branch.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
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
      nixpkgs-unstable,
      flake-utils,
      pre-commit-hooks,
      treefmt-nix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = import ./overlays { inherit icingaGroup icingaUser; };
        pkgs = import nixpkgs { inherit system overlays; };
        pkgsUnstable = import nixpkgs-unstable { inherit system overlays; };
        icingaGroup = "5665";
        icingaUser = "5665";
        packages = import ./packages {
          inherit
            icingaGroup
            icingaUser
            pkgs
            pkgsUnstable
            ;
        };
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
          update-packages = {
            type = "app";
            program = builtins.toString (
              pkgs.writers.writeNu "update-packages" ''
                ${pkgs.lib.getExe pkgs.nix-update} icinga-container-entrypoint --build --flake --version branch
                # todo pkgs.lib.getExe?
                ${treefmtEval.config.build.wrapper}/bin/treefmt
              ''
            );
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
