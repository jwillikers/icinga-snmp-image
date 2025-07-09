{ buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "icinga-container-entrypoint";
  version = "0-unstable-2025-06-17";

  src = fetchFromGitHub {
    owner = "Icinga";
    repo = "docker-icinga2";
    rev = "d8ba52f6a8820050313c60ed4a72d8ea17a22b9c";
    sha256 = "sha256-/hwEYtADT85jsyPSG4JKXKulkDqTzv7aAVb/FOTeE+k=";
  };
  sourceRoot = "${src.name}/entrypoint";

  vendorHash = "sha256-G7C+Pb8h+W6lph4YPWV3Drawj8u87mKML/p4Oan3XIc=";

  meta = {
    mainProgram = "entrypoint";
  };
}
