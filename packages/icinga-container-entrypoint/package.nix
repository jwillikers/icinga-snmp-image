{ buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "icinga-container-entrypoint";
  version = "0-unstable-2025-04-15";

  src = fetchFromGitHub {
    owner = "Icinga";
    repo = "docker-icinga2";
    rev = "d337394bd6b13a3539418980f0c7d5b1c0b0a6c8";
    sha256 = "sha256-B+M+kUAnrN5Lm7yKbaksk85JtO9q8W/BpRK1AjxuEY4=";
  };
  sourceRoot = "${src.name}/entrypoint";

  vendorHash = "sha256-f88WzC4foW+zLWYyk7qdwS+rC7m/iG0v4Z0i2hczHq8=";

  meta = {
    mainProgram = "entrypoint";
  };
}
