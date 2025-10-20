{ buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "icinga-container-entrypoint";
  version = "0-unstable-2025-10-13";

  src = fetchFromGitHub {
    owner = "Icinga";
    repo = "docker-icinga2";
    rev = "88dc9ff621af811bee2c8674eb35d81957c4dc7c";
    sha256 = "sha256-2daahUBo+Jz+5xOXIQakKkhEyP4CmdNPKszriB34x4Q=";
  };
  sourceRoot = "${src.name}/entrypoint";

  vendorHash = "sha256-XD3/W5W5UEUV4IiKUupDWLidPdFtrBsp9hInFSybf8A=";

  meta = {
    mainProgram = "entrypoint";
  };
}
