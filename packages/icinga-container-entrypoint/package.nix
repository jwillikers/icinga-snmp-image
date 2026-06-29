{ buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "icinga-container-entrypoint";
  version = "0-unstable-2026-06-25";

  src = fetchFromGitHub {
    owner = "Icinga";
    repo = "docker-icinga2";
    rev = "e059eccf16fcbb6b36079ea54158a0341765ce06";
    sha256 = "sha256-zl3KeRd4VYOsRUyKEth0H7pAvTCnJ51A8sNk/+ZE4aY=";
  };
  sourceRoot = "${src.name}/entrypoint";

  vendorHash = "sha256-loIOutu+1l6u3UfxdTQQIX45NREaZxfrGaByktgKngE=";

  meta = {
    mainProgram = "entrypoint";
  };
}
