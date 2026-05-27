{ buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "icinga-container-entrypoint";
  version = "0-unstable-2026-05-18";

  src = fetchFromGitHub {
    owner = "Icinga";
    repo = "docker-icinga2";
    rev = "e8107d6977c81ed5649fcd1688a40d029d181ecb";
    sha256 = "sha256-jCUo0LY7t32kBuoz9kBva0TKXU/J6E0myFmSI7sl6l0=";
  };
  sourceRoot = "${src.name}/entrypoint";

  vendorHash = "sha256-yEL5DToMDQQ8rD3or/xg3COE4vxzLrVjdHfvraGuQmQ=";

  meta = {
    mainProgram = "entrypoint";
  };
}
