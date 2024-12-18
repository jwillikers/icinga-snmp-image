{ buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "icinga-container-entrypoint";
  version = "0-unstable-2024-11-20";

  src = fetchFromGitHub {
    owner = "Icinga";
    repo = "docker-icinga2";
    rev = "116c03240a3a6b6d7875fb7e2e47457895fc8cf3";
    sha256 = "sha256-3GyOrsEI9VJ91LGNQ5r0yzRfEt0477KQMkC+HDAMG44=";
  };
  patches = [
    # Without this, we get error messages like:
    # vendor/golang.org/x/sys/unix/mremap.go:41:10: unsafe.Slice requires go1.17 or later (-lang was set to go1.16; check go.mod)
    # The patch was generated by changing "go 1.16" to "go 1.21" and executing `go mod tidy`.
    ./0001-Update-go-version-in-go.mod.patch
  ];
  sourceRoot = "${src.name}/entrypoint";

  vendorHash = "sha256-Trqxo8UNfZf5wrfHfIko4vLG/GmgsEXLBMk4NlzL3vM=";

  meta = {
    mainProgram = "entrypoint";
  };
}
