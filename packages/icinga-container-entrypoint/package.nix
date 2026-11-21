{ buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "icinga-container-entrypoint";
  version = "0-unstable-2026-11-11";

  src = fetchFromGitHub {
    owner = "Icinga";
    repo = "docker-icinga2";
    rev = "9b7c021f50f1a3bdc52466fff7aebe8efddb2a37";
    sha256 = "sha256-KPwXhxGlY7x8LKyrSszmJpHg/SavFkUtx49TyBxEUJw=";
  };
  sourceRoot = "${src.name}/entrypoint";

  vendorHash = "sha256-80+6QM7uo+PoZmDcaXmnRR3LEmUbxLrWwlyoNeALRoo=";

  meta = {
    mainProgram = "entrypoint";
  };
}
