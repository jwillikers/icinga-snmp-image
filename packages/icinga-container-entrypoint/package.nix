{ buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "icinga-container-entrypoint";
  version = "0-unstable-2026-08-17";

  src = fetchFromGitHub {
    owner = "Icinga";
    repo = "docker-icinga2";
    rev = "71fe89f8d30b944d11a835022383aae1dbd14ee6";
    sha256 = "sha256-gsX4n/CkCvJ4Qpg9y/p0yO//Ri3VsU0F3ST6ysh4BAo=";
  };
  sourceRoot = "${src.name}/entrypoint";

  vendorHash = "sha256-Fu5Cax5W/Ozzg5+RVNxOebH4x4C0c2yfLUkH4VN1AJE=";

  meta = {
    mainProgram = "entrypoint";
  };
}
